import { setNavbar } from '../components/navbar.js';
import { getHost, getCookie, getPartial } from '../config.js';


var canvas;
var context
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

document.addEventListener("DOMContentLoaded", async function(event) { 
	await getPartial('navbar', '../components/navbar.html')
  .then(()=> {setNavbar()})
});

window.onload = function () {
  canvas = document.getElementById("canvas");
  context = canvas.getContext("2d");
  video = document.getElementById("video");
  inputBtn = document.querySelector('#input');
  takePicBtn = document.querySelector('#takePicBtn');
  playerBtn = document.querySelector('#playerBtn');
  run();
};

function run() {
  mouseEventHandler();
  keyEventHandler();

  inputBtn.addEventListener('change', loadImg);

  playerBtn.addEventListener("click", async (ev) => {
    pause = !pause;
    changePlayerVideoStatus(pause)
    ev.preventDefault();
  }, false)

  takePicBtn.addEventListener("click", async (ev) => {
    unselectAll();
    resetCanvas();
    addImage()
    takepicture();
    ev.preventDefault();
  }, false)

  navigator.mediaDevices.getUserMedia({ video: true }).then((stream) => {
    video.srcObject = stream;
  })

  video.addEventListener("play", () => {
    setInterval(function () {
      setForeground();
      resetCanvas();
      addImage()
      deleteImg();
    }, 1000 / 30);
  });
}

function resetCanvas() {
  context.fillStyle = '#fff';
  context.fillRect(0, 0, canvas.width, canvas.height);
}

function keyEventHandler()
{
  document.querySelector('body').addEventListener("keydown", function (event) {
    if (event.key === "Enter") {
      unselectAll();
      resetCanvas();
      addImage()
      takepicture();
      event.preventDefault();
    }
  });

  document.body.onkeyup = function (event) {
    if (event.code == "Space") {
      event.preventDefault();
      pause = !pause;
      changePlayerVideoStatus(pause)
    } 
  };
}

function changePlayerVideoStatus(pause)
{
  var css;
  playerBtn.style.backgroundColor = "";
  if (pause)
  {
    playerBtn.src = playIconPath;
    playerBtn.style.border = "5px solid #03f517"
    css = '#playerBtn:hover{ background-color: #03f517;}'
    playerBtn.cssText = css;
    video.pause();
  }
  else
  {
    playerBtn.src = pauseIconPath;
    playerBtn.style.backgroundColor = "";
    playerBtn.style.border = "5px solid #f3ac06"
    css = '#playerBtn:hover{ background-color: #f3ac06; }'
    playerBtn.cssText = css;
    video.play();
  } 
}

function mouseEventHandler()
{
  canvas.onmousedown = function (e) {
    var mouseX = e.pageX - this.offsetLeft;
    var mouseY = e.pageY - this.offsetTop;

    for (let data of pic.reverse()) {
      if (data.toRemove)
        continue;

      if (isInZone(mouseX, mouseY, data.currentX - data.img.width / 2, data.currentY - data.img.height / 2, data.img.width, data.img.height)) {
        unselectAll();
        data.isDraggable = true;
        data.isSelected = true;
        data.foreground = true;
        return;
      }

      if (isInZone(mouseX, mouseY, data.currentX + data.img.width / 2, data.currentY - (data.img.height / 2) - iconSize, iconSize, iconSize)) {
        data.toResize = true;
        data.foreground = true;
        return;
      }

      if (isInZone(mouseX, mouseY, data.currentX - (data.img.width / 2) - iconSize, data.currentY - (data.img.height / 2) - iconSize, iconSize, iconSize)) {
        data.toRemove = true;
        data.isSelected = false;
        data.isDraggable = false;
      }
    }
  }

  canvas.onmousemove = function (e) {
    var mouseX = (e.pageX - this.offsetLeft);
    var mouseY = (e.pageY - this.offsetTop);
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

function drawCanvas()
{
  for (let data of pic)
  {
    if (!data.toRemove)
      context.drawImage(data.img, (data.currentX - (data.img.width / 2)), (data.currentY - (data.img.height / 2)), data.img.width, data.img.height);
    else
      continue;

    if (data.isSelected)
    {
      context.beginPath();
      context.rect(data.currentX - (data.img.width / 2), data.currentY - (data.img.height / 2), data.img.width, data.img.height);
      context.stroke();
      context.beginPath();
      context.arc(data.currentX, data.currentY, 5, 0, 2 * Math.PI);
      context.fill();
      context.stroke();
      context.drawImage(resizeIco, data.currentX + (data.img.width / 2), data.currentY - (data.img.height / 2) - 30, 30, 30);
      context.drawImage(deleteIco, data.currentX - (data.img.width / 2) - 30, data.currentY - (data.img.height / 2) - 30, 30, 30);
    }
  }
}

function addImg(path)
{
  var newImg = new Image();
  newImg.src = path;
  newImg.width = (!newImg.width || newImg.width > canvas.width) ? canvas.width / 3 : newImg.width;
  newImg.height = (!newImg.height || newImg.height > canvas.height) ? canvas.height / 3 : newImg.height;
  let data = {}
  data.id = imgId++;
  data.source = path.slice(0, 25);;
  data.foreground = false;
  data.toResize = false;
  data.toRemove = false
  data.isSelected = false;
  data.toRotate = false;
  data.currentX = canvas.width / 2;
  data.currentY = canvas.height / 2;
  data.img = newImg;
  data.isDraggable = false;
  pic.push(data);
}

function deleteImg()
{
  for (let i = pic.length - 1; -1 < i; i--) {
    if (pic[i].toRemove)
      ;// delete pic[i];
  }
}

function setForeground()
{
  for (let data of pic) {
    if (data.foreground) {
      //   console.log("PIC =>");
      // console.log(pic);
      break;
    }
  }

  for (var i = pic.length - 1; -1 < i; i--)
  {
    if (pic[i] && pic[i].foreground) {
      pic[i].foreground = false;

      console.log(pic);
      const element = pic.splice(i, 1)[0];
      console.log("PIC splice=>");
      console.log(pic);
      console.log(element);

      pic.push(element);
      console.log("NEW PIC=>");
      console.log(pic);
    }
  }
}

function unselectAll()
{
  for (let data of pic)
    data.isSelected = false;
}

function loadImg()
{
  if (this.files && this.files[0]) {
    var img = document.querySelector('#inputImg');
    img.onload = () => {
      URL.revokeObjectURL(img.src);
    }
    var file = URL.createObjectURL(this.files[0]);
    img.src = file;
    addImg(img.src)
  }
}

function isInZone(mouseX, mouseY, x, y, width, height)
{
  return (mouseX >= x
    && mouseX <= x + width
    && mouseY >= y
    && mouseY <= y + height
  )
}

async function takepicture()
{
  canvas.style.border = "10px solid red"
  takePicBtn.style.backgroundColor = "red";
  const data = canvas.toDataURL("image/png");
  // photo.setAttribute("src", data);
  const blob = await new Promise(resolve => canvas.toBlob(resolve));
  postUpload(blob);
  await sleep(100);
  canvas.style.border = "10px solid black"
  takePicBtn.style.backgroundColor = "";
  return blob
  // } else {
  //   clearphoto();
  // }
}


function postUpload(blob)
{
  if (!blob) {
    console.error("no blob loaded")
    return;
  }

  const token = getCookie("token");
  if (token == "")
    return ;

  const formData = new FormData();
  formData.append(token, blob, "blob");
  const host = 'localhost';
  fetch(`http://${host}:1337/pictures`, {
    method: "POST",
    headers: {
      'Content-Type': 'multipart/form-data',
    },
    body: formData 
  })
    .then((response) => {
      if (response.ok)
        return response.json();
      else
        return Promise.reject(response.json());
    })
    .then((data) => {
      console.log('success:', data);
    })
    .catch(async (error) => {
      console.error('error:', "pictures has not been posted");
    });
}

function sleep(ms)
{
  return new Promise(resolve => setTimeout(resolve, ms));
}

function addImage()
{
  context.drawImage(video, 0, 0, 1000, 750);
  drawCanvas();
}


