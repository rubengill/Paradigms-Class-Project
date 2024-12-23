// Import dependencies
import "phoenix_html"
import { createPicker } from 'picmo';
// Import local files
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Import your game modules
import channel from "./game_channel"
import GameRenderer from "./game_renderer"


// Set up CSRF token for LiveView
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let Hooks = {};
Hooks.EmojiButton = {
  mounted() {
    this.el.addEventListener('click', () => {
      let picker = document.getElementById('picker');
      picker.style.display = picker.style.display === 'none' ? 'block' : 'none';
    });
  }
};

Hooks.EmojiPicker = {
  mounted() {
    this.initializePicker();
  },
  updated() {
    this.initializePicker();  // Re-initialize on update to handle re-rendering
  },
  initializePicker() {
    const rootElement = this.el;
    const messageInput = document.getElementById('messageInput');

    // If a picker already exists, let's remove it and create a new one
    if (rootElement.__picker) {
      // If there's any specific destroy method, use it, otherwise just dereference
      delete rootElement.__picker; // This line assumes no specific cleanup needed
    }

    // Create a new picker instance
    const picker = createPicker({
      rootElement,
      autoHide: true
    });

    picker.addEventListener('emoji:select', event => {
      messageInput.value += event.emoji;
      messageInput.dispatchEvent(new Event('input', { bubbles: true }));  // Make sure LiveView acknowledges the input
    });

    // Store the new picker instance
    rootElement.__picker = picker;
  }
};

Hooks.EmojiInput = {
  mounted() {
    console.log("EmojiInput hooked");
  }
};

// Initialize LiveSocket
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks  
})
// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// Connect if there are any LiveViews on the page
liveSocket.connect()

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Set up the game
// Listen for state updates and render the game
channel.on("state_update", state => {
  GameRenderer.render(state)
})

// Example: Handle user interactions (e.g., spawning units)
document.addEventListener("DOMContentLoaded", () => {
  // Ensure the DOM is fully loaded before adding event listeners

  // Example button for spawning a soldier unit
  const spawnSoldierButton = document.getElementById("spawn-soldier-button")
  if (spawnSoldierButton) {
    spawnSoldierButton.addEventListener("click", () => {
      channel.push("spawn_unit", { unit_type: "soldier" })
    })
  }

  // TODO: Add event listeners for other unit types and actions
})

// Export channel if needed elsewhere
export default channel
