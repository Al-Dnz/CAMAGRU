import { getHost, getCookie } from '../config.js';
import createCard from './components/pictureCard.js';

document.addEventListener("DOMContentLoaded", async function(event) { 
	if (getCookie("token") == "")
		redirectToConnectPage();

	const host = await getHost("./config.json");

	await getPartial('navbar', './components/navbar.html');
	await getPartial('template', './components/picture_card.html');

	fetch(`http://${host}:1337/data`)
	.then((response) => response.json())
	.then((data) => 
	{
		var list =  document.getElementById("dataList")
		for (let el of data)
		{			
			// var item = createDataBox(el);
			var item = createCard(el);
			list.appendChild(item);
			list.appendChild(document.createElement("br"));
		}
		return data;
	})
	.then((data) => console.log(data))
});

function redirectToPicTest()
{
	window.location.href = 'pic_test/pic_test.html';
	return false;
}

function redirectToCamera()
{
	window.location.href = 'camera/camera.html';
	return false;
}

function redirectToUpload()
{
	window.location.href = 'upload/upload.html';
}

function redirectToConnectPage()
{
	window.location.href = 'connect.html';
	return false;
}

document.getElementById("picTestBtn").addEventListener("click", () => window.location.href = 'pic_test/pic_test.html');
document.getElementById("camBtn").addEventListener("click", () => window.location.href = 'camera/camera.html');


async function getPartial(div, path)
{
	fetch(path)
		.then(function(response) {return response.text()})
		.then(function(body) {document.querySelector(`#${div}`).innerHTML = body;});
}
