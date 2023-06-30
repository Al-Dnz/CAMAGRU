import { getHost } from "../config.js";

const host = await getHost('../config.json')
const port = 5000;

function send()
{
	const login = document.getElementById("login");
	const password = document.getElementById("password");

	let data = 
	{
		login: login.value,
		password: password.value,
	}

	fetch(`http://${host}:${port}/connect`, {
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
		console.log('success:', data);
		if (data.token != null)
			document.cookie = "token" + "=" + data.token + "; Path=/"
		login.value = "";
		password.value = "";
		window.location.replace("../index.html");
	})
	.catch(async (error) => {
		error = await error;
		window.alert(error.error);
		console.error('error:', error); 
	});
}

document.getElementById("connectBtn").addEventListener("click",() => {send()});