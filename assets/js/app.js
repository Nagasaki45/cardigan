// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html";
import {Socket} from "phoenix";
import NProgress from "nprogress";
import {LiveSocket} from "phoenix_live_view";

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

let Hooks = {};

Hooks.draggable_hook = {
    mounted() {
        this.el.addEventListener("dragstart", e => {
            let target = e.target.closest(".droppable");
            e.dataTransfer.dropEffect = "move";
            e.dataTransfer.setData("from_is", target.getAttribute("type"));
            e.dataTransfer.setData("from_id", target.id);
            e.dataTransfer.setData("card_id", e.target.id);
        });
    }
};

Hooks.drop_zone = {
    mounted() {
        this.el.addEventListener("dragover", e => {
            e.preventDefault();
            e.dataTransfer.dropEffect = "move";
        });

        this.el.addEventListener("drop", e => {
            e.preventDefault();
            let target = e.target.closest(".droppable");
            let data = {
                from_is: e.dataTransfer.getData("from_is"),
                from_id: e.dataTransfer.getData("from_id"),
                card_id: e.dataTransfer.getData("card_id"),
                to_is: target.getAttribute("type"),
                to_id: target.id,
                x: e.clientX,
                y: e.clientY,
            };
            console.log(data);
            this.pushEvent("move", data);
        });
    }
};

let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks});

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start());
window.addEventListener("phx:page-loading-stop", info => NProgress.done());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket;
