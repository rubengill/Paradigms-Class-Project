import socket from "./socket"

let channel = socket.channel("game:lobby", {})

channel.join()
  .receive("ok", resp => {
    console.log("Joined game channel successfully", resp)
    window.playerId = resp.player_id // Store player ID
  })
  .receive("error", resp => { console.log("Unable to join", resp) })

// Handle incoming state updates
channel.on("state_update", state => {
  // TODO: Implement game state rendering
  console.log("Received game state:", state)
})

export default channel
