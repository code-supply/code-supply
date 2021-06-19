// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

declare global {
  interface Window {
    liveSocket: any
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: {
    Scroll: {
      mounted() {
        this.handleEvent("scroll", ({id}) => {
          let el = document.getElementById(id);
          el.scrollIntoView({behavior: "smooth"});
          let focusEls = el.getElementsByClassName('scrollfocus');
          var focusEl = focusEls[0] as HTMLElement;
          if (focusEl) {
            focusEl.focus({preventScroll: true});
          }
        })
      }
    },
    MaintainAttrs: {
      attrs() {
        return this.el.getAttribute("data-attrs").split(", ");
      },
      beforeUpdate() {
        this.prevAttrs = this.attrs().map(name => [name, this.el.getAttribute(name)]);
      },
      updated() {
        this.prevAttrs.forEach(([name, val]) => this.el.setAttribute(name, val));
      }
    }
  },
  uploaders: {
    GCS: (entries, onViewError) => {
      entries.forEach(entry => {
        let formData = new FormData();
        let {url, fields} = entry.meta;
        Object.entries(fields).forEach(([key, val]: [string, string]) => {
          formData.append(key, val);
        });
        formData.append("file", entry.file);
        let xhr = new XMLHttpRequest();
        onViewError(() => xhr.abort());
        xhr.onload = () => xhr.status === 204 || entry.error();
        xhr.onerror = () => entry.error();

        xhr.upload.addEventListener("progress", (event) => {
          if (event.lengthComputable){
            let percent = Math.round((event.loaded / event.total) * 100);
            entry.progress(percent);
          }
        })

        xhr.open("POST", url, true);
        xhr.send(formData);
      })
    }
  },
  params: {_csrf_token: csrfToken}
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
