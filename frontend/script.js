
document.addEventListener("DOMContentLoaded", async function(event) { 
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

async function getPartial(div, path)
{
	fetch(path)
		.then(function(response) {return response.text()})
		.then(function(body) {document.querySelector(`#${div}`).innerHTML = body;});
}


// function send()
// {
// 	var login = document.getElementById("login");
// 	var password = document.getElementById("password");
// 	var email = document.getElementById("email");

// 	data = 
// 	{
// 		login: login.value,
// 		password: password.value,
// 		email: email.value
// 	}

// 	// console.log(email + last_name + name);
// 	fetch('http://0.0.0.0:1337/register', {
// 		method: 'POST',
// 		headers: {
// 			// 'Content-Type': 'application/json',
// 		},
// 		body: JSON.stringify(data),
// 	})
// 	.then((response) => {
// 		if (response.ok)
// 			 return response.json();
// 		else
// 			return Promise.reject(response.json()); 
// 	  })
// 	.then((data) => {
// 		console.log('success:', data);
// 		login.value = "";
// 		password.value = "";
// 		email.value  = "";
// 	})
// 	.catch(async (error) => {
// 		data = await error;
// 		console.error('error:', data.error);
		 
// 	});
// }
