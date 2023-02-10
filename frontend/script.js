
document.addEventListener("DOMContentLoaded", function(event) { 
	getPartial('navbar', './components/navbar.html');
	getPartial('form', './components/form.html');
	// getPartial('videoContainer', './video.html');
});

function redirectToCamera()
{
	window.location.href = 'camera/camera.html';
	return false;
}

function getPartial(div, path)
{
	fetch(path)
		.then(function(response) {return response.text()})
		.then(function(body) {document.querySelector(`#${div}`).innerHTML = body;});
}

var c1 = "block max-w-sm p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"


fetch('http://localhost:1337/data')
	.then((response) => response.json())
	.then((data) => 
	{
		var list =  document.getElementById("dataList")
		for (let el of data)
		{
			var item = createDataBox(el);
			list.appendChild(item);
		}
		return data;
	})
	.then((data) => console.log(data))
	
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


function send()
{
	var first_name = document.getElementById("first_name").value
	var last_name = document.getElementById("last_name").value
	var email = document.getElementById("email").value

	data = 
	{
		first_name: first_name,
		last_name: last_name,
		email: email
	}

	// console.log(email + last_name + name);
	fetch('http://0.0.0.0:1337/data', {
		method: 'POST',
		headers: {
			// 'Content-Type': 'application/json',
		},
		body: JSON.stringify(data),
	})
	.then((response) => response.json())
	.then((data) => {
	  console.log('Success:', data);
	})
	.catch((error) => {
	  console.error('Error:', error);
	});
}