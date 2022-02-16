import "phoenix_html"
// @ts-ignore
import { Socket } from "phoenix"
// @ts-ignore
import { LiveSocket } from "phoenix_live_view"

declare global {
  interface Window {
    liveSocket: any
  }
}

interface FileMeta {
  url: any
  fields: any
}

interface FileEntry {
  meta: FileMeta
  file: string | Blob
  error: () => void
  progress: (percent: number) => void
}

interface Resize {
  el: HTMLElement
  styleAttr: string
  barSize: number
  measuringElement: (pos: number) => HTMLElement
  calculateSize: (e: MouseEvent, el: HTMLElement) => number
  mouseup: (e: MouseEvent, originalPos: string, elForMeasuring: HTMLElement) => void
}

const resize = function({ el, styleAttr, barSize, measuringElement, calculateSize, mouseup }: Resize) {
  const editorPos = el.dataset.editorPos;
  const originalPos = el.dataset.originalPos;
  const prevEditorPos = parseInt(editorPos, 10);
  const elForMeasuring: HTMLElement = measuringElement(prevEditorPos);
  let dragging = false;

  el.addEventListener("mousedown", () => {
    dragging = true;
  });

  document.addEventListener("mousemove", (e) => {
    if (dragging) {
      const size = calculateSize(e, elForMeasuring);
      const container: HTMLElement = el.parentElement;
      const templateSizes: string = container.style[styleAttr];
      const sizes = templateSizes.split(" ");
      sizes.splice(prevEditorPos, 1, `calc(${size}px - ${barSize}px)`);
      container.style[styleAttr] = sizes.join(" ");
    }
  });

  document.addEventListener("mouseup", (e) => {
    if (dragging) {
      mouseup(e, originalPos, elForMeasuring);
      dragging = false;
    }
  });
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: {
    Scroll: {
      mounted() {
        this.handleEvent("scroll", ({ id }) => {
          let el = document.getElementById(id);
          el.scrollIntoView({ behavior: "smooth" });
          let focusEls = el.getElementsByClassName('scrollfocus');
          var focusEl = focusEls[0] as HTMLElement;
          if (focusEl) {
            focusEl.focus({ preventScroll: true });
          }
        })
      }
    },
    MaintainAttrs: {
      attrs() {
        return this.el.getAttribute("data-attrs").split(", ");
      },
      beforeUpdate() {
        this.prevAttrs = this.attrs().map((name: string) => [name, this.el.getAttribute(name)]);
      },
      updated() {
        this.prevAttrs.forEach(([name, val]) => this.el.setAttribute(name, val));
      }
    },
    RowResize: {
      mounted() {
        resize({
          el: this.el,
          styleAttr: "gridTemplateRows",
          barSize: this.el.clientHeight,

          measuringElement: (pos: number) =>
            document.querySelector(`[data-last-row="${pos}"]`),

          calculateSize: (e: MouseEvent, el: HTMLElement) =>
            Math.floor((el.clientHeight + e.clientY - el.getBoundingClientRect().bottom)),

          mouseup: (e: MouseEvent, originalPos: string, elForMeasuring: HTMLElement) =>
            this.pushEventTo(this.el, "resizeRow", {
              row: originalPos,
              height: elForMeasuring.clientHeight + e.clientY - elForMeasuring.getBoundingClientRect().bottom
            }),
        });
      }
    },
    ColumnResize: {
      mounted() {
        resize({
          el: this.el,
          styleAttr: "gridTemplateColumns",
          barSize: this.el.clientWidth,

          measuringElement: (pos: number) =>
            document.querySelector(`[data-last-col="${pos}"]`),

          calculateSize: (e: MouseEvent, el: HTMLElement) =>
            Math.floor((el.clientWidth + e.clientX - el.getBoundingClientRect().right)),

          mouseup: (e: MouseEvent, originalPos: string, elForMeasuring: HTMLElement) =>
            this.pushEventTo(this.el, "resizeColumn", {
              column: originalPos,
              width: elForMeasuring.clientWidth + e.clientX - elForMeasuring.getBoundingClientRect().right
            }),
        });
      }
    }
  },
  uploaders: {
    GCS: (entries: FileEntry[], onViewError: (callback: () => void) => void) => {
      entries.forEach((entry) => {
        let formData = new FormData();
        let { url, fields } = entry.meta;
        Object.entries(fields).forEach(([key, val]: [string, string]) => {
          formData.append(key, val);
        });
        formData.append("file", entry.file);
        let xhr = new XMLHttpRequest();
        onViewError(() => xhr.abort());
        xhr.onload = () => xhr.status === 204 || entry.error();
        xhr.onerror = () => entry.error();

        xhr.upload.addEventListener("progress", (event) => {
          if (event.lengthComputable) {
            let percent = Math.round((event.loaded / event.total) * 100);
            entry.progress(percent);
          }
        })

        xhr.open("POST", url, true);
        xhr.send(formData);
      })
    }
  },
  params: { _csrf_token: csrfToken }
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
