// Create references to the video and canvas elements
const video = document.getElementById("video");
const canvas = document.getElementById("canvas");
// Get canvas contexts
const context = canvas.getContext("2d");

navigator.mediaDevices.getUserMedia({ video: true }).then((stream) => {
  video.srcObject = stream;
});

video.addEventListener("play", () => {
  setInterval(addImage, 0);
});

function addImage() {
  // User Video
  context.drawImage(video, 0, 0, 1000, 750);
  // Overlay Image
  const overlayImg = new Image();
  overlayImg.src = "../images/ico.png";

  context.drawImage(overlayImg, 10, 10, 35, 30); // x, y of top-left, width, height
}
