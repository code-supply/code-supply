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
  localIndexOffset: number
  calculateSize: (e: MouseEvent) => number
  saveSize: (e: MouseEvent, index: string) => void
  setExpandable: (index: string) => void
}

const resize = function({ el, styleAttr, localIndexOffset, calculateSize, saveSize, setExpandable }: Resize) {
  const [_a, _b, index] = el.id.split("_");
  const elForMeasuring = el.parentElement;
  const gridContainer: HTMLElement = elForMeasuring.parentElement;
  let dragging = false;

  el.addEventListener("contextmenu", (e: PointerEvent) => {
    e.preventDefault();
  });

  el.addEventListener("mousedown", (e: MouseEvent) => {
    if (e.button == 0) {
      dragging = true;
    }
  });

  el.addEventListener("mouseup", (e: MouseEvent) => {
    if (e.button == 2) {
      setExpandable(index);
    }
  });

  document.addEventListener("mousemove", (e) => {
    if (dragging) {
      const size = calculateSize(e);
      const templateSizes: string = gridContainer.style[styleAttr];
      const sizes = templateSizes.split(" ");
      sizes[parseInt(index, 10) + localIndexOffset] = `${size}px`;
      gridContainer.style[styleAttr] = sizes.join(" ");
    }
  });

  document.addEventListener("mouseup", (e: MouseEvent) => {
    if (dragging) {
      saveSize(e, index);
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
          localIndexOffset: 1,

          calculateSize: (e: MouseEvent) =>
            Math.floor((this.el.parentElement.clientHeight + e.clientY - this.el.parentElement.getBoundingClientRect().bottom)),

          saveSize: (e: MouseEvent, index: string) => {
            this.pushEventTo(this.el, "resizeRow", {
              row: index,
              height: this.el.parentElement.clientHeight + e.clientY - this.el.parentElement.getBoundingClientRect().bottom + "px"
            })
          },

          setExpandable: (index: string) => {
            this.pushEventTo(this.el, "resizeRow", {
              row: index,
              height: "1fr"
            })
          },
        });
      }
    },
    ColumnResize: {
      mounted() {
        resize({
          el: this.el,
          styleAttr: "gridTemplateColumns",
          localIndexOffset: 0,

          calculateSize: (e: MouseEvent) =>
            Math.floor((this.el.parentElement.clientWidth + e.clientX - this.el.parentElement.getBoundingClientRect().right)),

          saveSize: (e: MouseEvent, index: string) => {
            this.pushEventTo(this.el, "resizeColumn", {
              column: index,
              width: this.el.parentElement.clientWidth + e.clientX - this.el.parentElement.getBoundingClientRect().right + "px"
            });
          },

          setExpandable: (index: string) => {
            this.pushEventTo(this.el, "resizeColumn", {
              column: index,
              width: "1fr"
            });
          },
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
