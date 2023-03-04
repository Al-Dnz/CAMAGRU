import { getHost } from "../config.js";

const host = await getHost('../config.json')

function send()
{
	const login = document.getElementById("login");
	const password = document.getElementById("password");

	let data = 
	{
		login: login.value,
		password: password.value,
	}

	fetch(`http://${host}:1337/connect`, {
		method: 'POST',
		headers: {
			// 'Content-Type': 'application/json',
		},
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
			document.cookie = "token" + "=" + data.token
		login.value = "";
		password.value = "";
		window.location.href = './index.html';
	})
	.catch(async (error) => {
		data = await error;
		console.error('error:', data.error); 
	});
}

document.getElementById("connectBtn").addEventListener("click",() => {send()});