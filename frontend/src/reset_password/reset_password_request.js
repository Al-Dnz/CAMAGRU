import { getCookie, getHost } from "../config.js";

const host = await getHost('../config.json')
const port = 5000;

function send()
{
	
	// const password = document.getElementById("password");
	const email = document.getElementById("email");
	const confirmationDiv = document.querySelector("#confirmationDiv");
	const confirmationMessage = document.querySelector("#confirmationMessage");

	let data = 
	{
		email: email.value
		// token: getCookie("token")
	}
	console.log("send =>");
	console.log(data);

	fetch(`http://${host}:${port}/reset_password_request`, {
		method: 'POST',
		headers: {},
		body: JSON.stringify(data),
	})
	.then((response) => {
		if (response.ok)
			 return response.json();
		else
			return Promise.reject(response.json()); 
	  })
	.then((data) => {
		email.value = "";
		console.log('success:', data);
		return data;
	})
	.then((data) => {
		confirmationDiv.style.display = "";
		confirmationMessage.innerHTML = `${data.email}`;
	})
	.catch(async (error) => {
		error = await error;
		window.alert(error.error);
		console.error('error:', error); 
	});
}

document.getElementById("resetLinkBtn").addEventListener("click",() => {send()});