// assets/js/emoji.js
import { createPicker } from 'picmo';

export function initEmojiPicker() {
    document.addEventListener('DOMContentLoaded', function () {
        const rootElement = document.querySelector('#picker');
        const emojiButton = document.getElementById('emoji-button');

        // Initialize the picker and hide it initially
        const picker = createPicker({
            rootElement,  // Ensure this is an empty div where the picker should appear
            autoHide: false // Optional based on whether you want the picker to hide automatically
        });
        rootElement.style.display = 'none'; // Hide the picker initially

        // Event listener for emoji selection
        picker.addEventListener('emoji:select', event => {
            const messageInput = document.getElementById('messageInput');
            messageInput.value += event.emoji; // Append selected emoji to the input field
        });

        // Toggle the visibility of the picker when the button is clicked
        emojiButton.addEventListener('click', () => {
            if (rootElement.style.display === 'none') {
                rootElement.style.display = 'block';
            } else {
                rootElement.style.display = 'none';
            }
        });
    });
}