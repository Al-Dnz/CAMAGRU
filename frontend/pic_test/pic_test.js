import { setNavbar } from "../components/navbar.js";
import { getHost, getCookie, getPartial, generateUUID } from "../config.js";

const token = getCookie("token");
if (token == "") 
	window.location.replace("../index.html");

var host;
var canvas;
var context;
var video;
var inputBtn;
var takePicBtn;
var playerBtn;

var resizeIco = new Image();
resizeIco.src = "../images/resize_icon.png";
var deleteIco = new Image();
deleteIco.src = "../images/delete_icon.png";

var startX = 0;
var startY = 0;
let imgId = 1;
var pic = [];
var pause = false;
const iconSize = 30;
const playIconPath = "../images/play_icon.png";
const pauseIconPath = "../images/pause_icon.png";

document.addEventListener("DOMContentLoaded", async function (event) {
  await getPartial("navbar", "../components/navbar.html").then(() => {
    setNavbar();
  });
  host = await getHost("../config.json");
});

window.onload = function () {
  canvas = document.getElementById("canvas");
  context = canvas.getContext("2d");
  video = document.getElementById("video");
  inputBtn = document.querySelector("#input");
  takePicBtn = document.querySelector("#takePicBtn");
  playerBtn = document.querySelector("#playerBtn");
  run();
};

function run() {
  mouseEventHandler();
  keyEventHandler();

  inputBtn.addEventListener("change", loadImg);

  playerBtn.addEventListener(
    "click",
    async (ev) => {
      pause = !pause;
      changePlayerVideoStatus(pause);
      ev.preventDefault();
    },
    false
  );

  takePicBtn.addEventListener(
    "click",
    async (ev) => {
      unselectAll();
      resetCanvas();
      addImage();
      takepicture();
      ev.preventDefault();
    },
    false
  );

  navigator.mediaDevices.getUserMedia({ video: true }).then((stream) => {
    video.srcObject = stream;
  });

  video.addEventListener("play", () => {
    setInterval(function () {
      setForeground();
      resetCanvas();
      addImage();
      deleteImg();
    }, 1000 / 30);
  });
}

function resetCanvas() {
  context.fillStyle = "#fff";
  context.fillRect(0, 0, canvas.width, canvas.height);
}

function keyEventHandler() {
  document.querySelector("body").addEventListener("keydown", function (event) {
    if (event.key === "Enter") {
      unselectAll();
      resetCanvas();
      addImage();
      takepicture();
      event.preventDefault();
    }
    if (event.key === "Escape")
	{
		pic = [];
	}
	
  });

  document.body.onkeyup = function (event) {
    if (event.code == "Space") {
      event.preventDefault();
      pause = !pause;
      changePlayerVideoStatus(pause);
    }
  };
}

function changePlayerVideoStatus(pause) {
  var css;
  playerBtn.style.backgroundColor = "";
  if (pause) {
    playerBtn.src = playIconPath;
    playerBtn.style.border = "5px solid #03f517";
    css = "#playerBtn:hover{ background-color: #03f517;}";
    playerBtn.cssText = css;
    video.pause();
  } else {
    playerBtn.src = pauseIconPath;
    playerBtn.style.backgroundColor = "";
    playerBtn.style.border = "5px solid #f3ac06";
    css = "#playerBtn:hover{ background-color: #f3ac06; }";
    playerBtn.cssText = css;
    video.play();
  }
}

function mouseEventHandler() {
  canvas.onmousedown = function (e) {
    var mouseX = e.pageX - this.offsetLeft;
    var mouseY = e.pageY - this.offsetTop;

    for (let data of pic.reverse()) {
      if (data.toRemove) continue;

      if (
        isInZone(
          mouseX,
          mouseY,
          data.currentX - data.img.width / 2,
          data.currentY - data.img.height / 2,
          data.img.width,
          data.img.height
        )
      ) {
        unselectAll();
        data.isDraggable = true;
        data.isSelected = true;
        data.foreground = true;
        return;
      }

      if (
        isInZone(
          mouseX,
          mouseY,
          data.currentX + data.img.width / 2,
          data.currentY - data.img.height / 2 - iconSize,
          iconSize,
          iconSize
        )
      ) {
        data.toResize = true;
        data.foreground = true;
        return;
      }

      if (
        isInZone(
          mouseX,
          mouseY,
          data.currentX - data.img.width / 2 - iconSize,
          data.currentY - data.img.height / 2 - iconSize,
          iconSize,
          iconSize
        )
      ) {
        data.toRemove = true;
        data.isSelected = false;
        data.isDraggable = false;
      }
    }
  };

  canvas.onmousemove = function (e) {
    var mouseX = e.pageX - this.offsetLeft;
    var mouseY = e.pageY - this.offsetTop;
    var dx = mouseX - startX;
    var dy = mouseY - startY;
    for (let data of pic) {
      if (data.isDraggable) {
        data.currentX += dx;
        data.currentY += dy;
      }
      if (data.toResize) {
        data.img.width = (mouseX - data.currentX) * 2;
        data.img.height = (data.currentY - mouseY) * 2;
      }
    }
    startX = mouseX;
    startY = mouseY;
  };

  canvas.onmouseup = function (e) {
    for (let data of pic) {
      data.isDraggable = false;
      data.toResize = false;
      data.toRotate = false;
    }
  };

  canvas.onmouseout = function (e) {
    for (let data of pic) {
      data.isDraggable = false;
      data.toResize = false;
      data.toRotate = false;
    }
  };
}

function drawCanvas() {
  for (let data of pic) {
    if (!data.toRemove)
      context.drawImage(
        data.img,
        data.currentX - data.img.width / 2,
        data.currentY - data.img.height / 2,
        data.img.width,
        data.img.height
      );
    else continue;

    if (data.isSelected) {
      context.beginPath();
      context.rect(
        data.currentX - data.img.width / 2,
        data.currentY - data.img.height / 2,
        data.img.width,
        data.img.height
      );
      context.stroke();
      context.beginPath();
      context.arc(data.currentX, data.currentY, 5, 0, 2 * Math.PI);
      context.fill();
      context.stroke();
      context.drawImage(
        resizeIco,
        data.currentX + data.img.width / 2,
        data.currentY - data.img.height / 2 - 30,
        30,
        30
      );
      context.drawImage(
        deleteIco,
        data.currentX - data.img.width / 2 - 30,
        data.currentY - data.img.height / 2 - 30,
        30,
        30
      );
    }
  }
}

function addImg(path) {
  var newImg = new Image();
  newImg.src = path;
  newImg.width = !newImg.width || newImg.width > canvas.width ? canvas.width / 3 : newImg.width;
  newImg.height = !newImg.height || newImg.height > canvas.height ? canvas.height / 3 : newImg.height;
  let data = {};
  data.id = imgId++;
  data.source = path.slice(0, 25);
  data.foreground = false;
  data.toResize = false;
  data.toRemove = false;
  data.isSelected = false;
  data.toRotate = false;
  data.currentX = canvas.width / 2;
  data.currentY = canvas.height / 2;
  data.img = newImg;
  data.isDraggable = false;
  pic.push(data);
}

function deleteImg() {
  for (let i = pic.length - 1; -1 < i; i--) {
    if (pic[i].toRemove)
		; // delete pic[i];
  }
}

function setForeground() {
  for (let data of pic) {
    if (data.foreground) {
      break;
    }
  }

  for (var i = pic.length - 1; -1 < i; i--) {
    if (pic[i] && pic[i].foreground) {
      pic[i].foreground = false;
      const element = pic.splice(i, 1)[0];
      pic.push(element);
    }
  }
}

function unselectAll() {
  for (let data of pic) data.isSelected = false;
}

function loadImg() {
  if (this.files && this.files[0]) {
    var img = document.querySelector("#inputImg");
    img.onload = () => {
      URL.revokeObjectURL(img.src);
    };
    var file = URL.createObjectURL(this.files[0]);
    img.src = file;
    addImg(img.src);
  }
}

function isInZone(mouseX, mouseY, x, y, width, height) {
  return (
    mouseX >= x && mouseX <= x + width && mouseY >= y && mouseY <= y + height
  );
}

async function takepicture(){
  if (pic.length == 0)
	return;
  canvas.style.border = "10px solid red";
  takePicBtn.style.backgroundColor = "red";
  const data = canvas.toDataURL("image/png");
  const blob = await new Promise((resolve) => canvas.toBlob(resolve));
  postUpload(blob);
  storeBlob(blob, "album");
  await sleep(100);
  canvas.style.border = "10px solid black";
  takePicBtn.style.backgroundColor = "";
  return blob;
}

function postUpload(blob) {
  if (!blob) {
    console.error("no blob loaded");
    return;
  }

  const token = getCookie("token");
  if (token == "") 
  	return;

  const formData = new FormData();
  formData.append(token, blob, "blob");

  fetch(`http://${host}:1337/pictures`, {
    method: "POST",
    headers: {
      "Content-Type": "multipart/form-data",
    },
    body: formData,
  })
    .then((response) => {
      if (response.ok) return response.json();
      else return Promise.reject(response.json());
    })
    .then((data) => {
      console.log("success:", data);
    })
    .catch(async (error) => {
      console.error("error:", "pictures has not been posted");
      console.error(await error);
    });
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function addImage() {
  context.drawImage(video, 0, 0, 1000, 750);
  drawCanvas();
}

// =======================================

const stickersDiv = document.getElementById("stickers");
const url = "../stickers";

fetch(url)
  .then((response) => response.text())
  .then((text) => {
    const parser = new DOMParser();
    const htmlDocument = parser.parseFromString(text, "text/html");
    const links = Array.from(htmlDocument.querySelectorAll("a"));

    const files = links
      .map((link) => {
        const href = link.getAttribute("href");
        return href.startsWith("/") ? href.substr(1) : href;
      })
      .filter((href) => {
        return href !== "." && href !== "..";
      });

    return files;
  })
  .then((files) => {
    for (let file of files) {
      var img = document.createElement("img");
      img.src = "../stickers/" + file;
      let cssClasses = [
        "w-30",
        "h-30",
        "max-w-xs",
        "overflow-hidden",
        "rounded-lg",
        "shadow-md",
        "bg-white",
        "hover:shadow-xl",
        "transition-shadow",
        "duration-300",
        "ease-in-out",
      ];
      let div1 = document.createElement("div");
      div1.classList.add(...cssClasses);
      div1.appendChild(img);

      let div2 = document.createElement("div");
      div2.setAttribute("id", "sticker" + file);
      cssClasses = ["inline-block", "px-3"];
      div2.classList.add(...cssClasses);
      div2.appendChild(div1);

      document.getElementById("stickers").appendChild(div2);
      document
        .getElementById("sticker" + file)
        .addEventListener("click", (ev) => {
          addImg("../stickers/" + file);
        });
    }
  });

function storeBlob(blob, divId) {
  var img = document.createElement("img");
  var objectURL = URL.createObjectURL(blob);
  img.src = objectURL;
  let cssClasses = [
    "w-30",
    "h-30",
    "max-w-xs",
    "overflow-hidden",
    "rounded-lg",
    "shadow-md",
    "bg-white",
    "hover:shadow-xl",
    "transition-shadow",
    "duration-300",
    "ease-in-out",
  ];
  let div1 = document.createElement("div");
  div1.classList.add(...cssClasses);
  div1.appendChild(img);

  let div2 = document.createElement("div");
  let shotDivId = "shot_" + generateUUID();
  div2.setAttribute("id", shotDivId );
  div2.setAttribute("selected", false );
  cssClasses = ["inline-block", "px-3"];
  div2.classList.add(...cssClasses);
  div2.appendChild(div1);

  document.getElementById(divId).appendChild(div2);
//   document.getElementById(shotDivId).addEventListener("click", async (ev) => {await selectShot(shotDivId) });
}

let selectedBlobs = [];

async function selectShot(shotDivId)
{
	const shotDiv = document.getElementById(shotDivId);
	const state = shotDiv.getAttribute("selected");
	let cssClasses = ["border-solid", "border-4", "border-indigo-500/100"];

	if (state == "false")
	{
		shotDiv.setAttribute("selected", true );
		shotDiv.firstChild.classList.add(...cssClasses);
		let url = shotDiv.querySelector('img')
		selectedBlobs.push(url);
		console.log(selectedBlobs);
	}
	else
	{
		shotDiv.setAttribute("selected", false );
		shotDiv.firstChild.classList.remove(...cssClasses);
	}
}

