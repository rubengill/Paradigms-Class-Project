document.addEventListener("DOMContentLoaded", () => {
    const guestButton = document.querySelector("a[phx_click='show_guest_modal']");
    const guestModal = document.getElementById("guest-modal");
  
    guestButton.addEventListener("click", (e) => {
      e.preventDefault();
      guestModal.classList.add("show");
    });
  
    guestModal.addEventListener("click", (e) => {
      if (e.target === guestModal) {
        guestModal.classList.remove("show");
      }
    });
  });
  