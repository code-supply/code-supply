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
        const el = this.el;
        var dragging = false;
        el.addEventListener("mousedown", () => {
          dragging = true;
        });
        document.addEventListener("mousemove", (e) => {
          if (dragging) {
            this.pushEventTo(el, "resizeRowDrag", {
              row: el.dataset.row,
              offset: e.clientY - el.getBoundingClientRect().top
            });
          }
        });
        document.addEventListener("mouseup", () => {
          if (dragging) {
            this.pushEventTo(el, "resizeRow");
            dragging = false;
          }
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
