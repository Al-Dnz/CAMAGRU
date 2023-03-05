import { getHost, getCookie, getPartial } from '../config.js';
import { setNavbar } from './components/navbar.js';
import createCard from './components/pictureCard.js';

document.addEventListener("DOMContentLoaded", async function(event) { 
	
	const host = await getHost("./config.json");

	await getPartial('navbar', './components/navbar.html')
	.then(()=> {
		setNavbar();
		// const settingsBtn = document.getElementById("settingsBtn");
		// const picBtn = document.getElementById("picBtn");
		// const powerBtn = document.getElementById("powerBtn");

		// if (getCookie("token") != "")
		// {
		// 	picBtn.style.display = "";
		// 	settingsBtn.style.display = "";
		// 	powerBtn.querySelector("svg").classList.add("text-white");
		// 	powerBtn.status = "on";
		// }


		// powerBtn.addEventListener("click", () => 
		// {
		// 	if (powerBtn.status == "on")
		// 	{
		// 		document.cookie = "token" + "=";
		// 		window.location.replace("./index.html");
		// 	}
		// 	else
		// 	{
		// 		window.location.replace("./connect.html");
		// 	}
		// });
	})

	
	fetch(`http://${host}:1337/data`)
	.then((response) => response.json())
	.then((data) => 
	{
		data = data.reverse();
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
	.then((data) => {
		// console.log(data);
	})
	
});