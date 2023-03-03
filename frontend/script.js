import getCookie  from './config.js';

(async () => {
document.addEventListener("DOMContentLoaded", async function(event) { 
	if (getCookie("token") == "")
		redirectToConnectPage();

	await getPartial('navbar', './components/navbar.html');
	await getPartial('form', './components/form.html');
	await getPartial('template', './components/picture_card.html');

	fetch('http://localhost:1337/data')
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

// function getCookie(cname) {
// 	let name = cname + "=";
// 	let decodedCookie = decodeURIComponent(document.cookie);
// 	let ca = decodedCookie.split(';');
// 	for(let i = 0; i <ca.length; i++) {
// 	  let c = ca[i];
// 	  while (c.charAt(0) == ' ') {
// 		c = c.substring(1);
// 	  }
// 	  if (c.indexOf(name) == 0) {
// 		return c.substring(name.length, c.length);
// 	  }
// 	}
// 	return "";
//   }

function createCard(element)
{
	// var tempNode = document.querySelector("div[data-type='picture_card_template']").cloneNode(true); //true for deep clone
	var tempNode = document.querySelector("#templateCard").cloneNode(true); //true for deep clone
	tempNode.querySelector("img").src =element.path
	tempNode.querySelector("p").innerHTML = element.content
	tempNode.style.display = "block";
	return tempNode;
}

function createDataBox(element)
{
	var newItem = document.createElement("li");
	var text = "";
	for (let key of Object.keys(element))
		text = text + " " + key + "=>" + " " + element[key]
	var newContent = document.createTextNode(text);
	newItem.appendChild(newContent);
	return newItem;
}


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

async function getPartial(div, path)
{
	fetch(path)
		.then(function(response) {return response.text()})
		.then(function(body) {document.querySelector(`#${div}`).innerHTML = body;});
}
})()
