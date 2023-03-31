import { getHost, getCookie, getPartial } from '../config.js';
import { setNavbar } from './components/navbar.js';
import createCard from './components/pictureCard.js';
import createCommentBox from './components/commentBox.js';

document.addEventListener("DOMContentLoaded", async function(event) { 
	
	const host = await getHost("./config.json");
	await getPartial('navbar', './components/navbar.html').then(()=> { setNavbar() })
	const user  = await getUser(host);
	await getPictures(host);
	await getLikes(user, host);
	await getComments(host);
});

async function getPictures(host)
{
	await fetch(`http://${host}:1337/data`)
	.then((response) => response.json())
	.then((data) => 
	{
		data = data.reverse();
		var list =  document.getElementById("dataList")
		for (let el of data)
		{			
			var item = createCard(el);
			list.appendChild(item);
			list.appendChild(document.createElement("br"));

			const sendBtn = document.getElementById(`sendComment${el.id}`);
			const comment = document.getElementById(`inputComment${el.id}`);
			sendBtn.addEventListener("click", () => { postComment(host, comment, el.id) });

			const likeBtn = document.getElementById(`pictureCardLike${el.id}`);
			likeBtn.addEventListener("click", async () => { await pictureCardLikeHandler(host, el.id) });
		}
		return data;
	})
	.then((data) => {})
}

async function getComments(host)
{
	await fetch(`http://${host}:1337/comment`)
	.then((response) => response.json())
	.then((comments) => 
	{
		for (let comment of comments)
		{		
			let divId = `pictureCard${comment.picture_id}`	
			var card = document.getElementById(divId);
			if (!card)
				continue;
			var box = createCommentBox(comment);
			var commentDiv = card.querySelector('.comments');
			if (!commentDiv)
				continue;
			commentDiv.appendChild(box);
		}
		return comments;
	})
	.then((data) => {})
}

async function postComment(host, comment, id)
{
	let token = getCookie("token");
	if (token == "")
	{
		alert("You should be connected to post comment");
		console.error("no token found")
		return;
	}
	const data = 
	{
		picture_id: parseInt(id, 10),
		token: token,
		content: comment.value
	};

	await fetch(`http://${host}:1337/comment`,
	{
		method: 'POST',
		headers: {},
		body: JSON.stringify(data),
	})
	.then((response) => 
	{
		if (response.ok)
			return response.json();
		else
			return Promise.reject(response.json()); 
	})
	.then((res) => 
	{
		comment.value = "";
		let divId = `pictureCard${res.picture_id}`	
		var card = document.getElementById(divId);
		if (!card)
			return;
		var box = createCommentBox(res);
		var commentDiv = card.querySelector('.comments');
		if (!commentDiv)
			return;
		commentDiv.appendChild(box);
	})
	.catch(async (err) => 
	{
		let error = await err;
		console.error("error in posting comment: ");
		console.error(error);
	})
}

async function pictureCardLikeHandler(host, pictureId)
{
	const likeBtn = document.getElementById(`pictureCardLike${pictureId}`);
	let activated = likeBtn.getAttribute("activated") == "true";
	activated = !activated
	likeBtn.setAttribute('activated', `${activated}`);

	let token = getCookie("token");
	if (token == "")
	{
		alert("You should be connected to like pictures");
		console.error("no token found")
		return;
	}
	const data = 
	{
		method: "",
		token: token,
		picture_id: parseInt(pictureId, 10)
	}
	if (activated)
	{
		data.method = "POST";
		await fetch(`http://${host}:1337/like`,
		{
			method: 'POST',
			headers: {},
			body: JSON.stringify(data),
		})
		.then((response) => 
		{
			if (response.ok)
				return response.json();
			else
				return Promise.reject(response.json()); 
		})
		.then((res) => 
		{
			likeBtn.querySelector('svg').classList.add('text-red-500');
			likeBtn.querySelector('svg').classList.add('fill-red-500');
		})
		.catch(async (err) => 
		{
			likeBtn.setAttribute('activated', `${false}`);
			console.error(err);
		})
	}
	else
	{	
		data.method = "DELETE";
		await fetch(`http://${host}:1337/like`,
		{
			method: 'POST',
			headers: {},
			body: JSON.stringify(data),
		})
		.then((response) => 
		{
			if (response.ok)
				return response.json();
			else
				return Promise.reject(response.json()); 
		})
		.then((res) => 
		{
			likeBtn.querySelector('svg').classList.remove('text-red-500');
			likeBtn.querySelector('svg').classList.remove('fill-red-500');
		})
		.catch(async (err) => 
		{
			likeBtn.setAttribute('activated', `${true}`);
			console.error(err);
		})
		
	}
}

async function getLikes(user, host)
{
	
	await fetch(`http://${host}:1337/like`,
		{
			method: 'GET',
			headers: {}
		})
		.then((response) => 
		{
			if (response.ok)
				return response.json();
			else
				return Promise.reject(response.json()); 
		})
		.then((res) => 
		{
			for(let data of res)
			{
				let likeBtn = document.getElementById(`pictureCardLike${data.picture_id}`);
				let likers = [];

				if (user && data.user_id == user.id)
				{
					likeBtn.setAttribute('activated', `${true}`);
					likeBtn.querySelector('svg').classList.add('text-red-500');
					likeBtn.querySelector('svg').classList.add('fill-red-500');
				}
				else
					likers.push(data.user);
				
				let str = "";
				if (likers.length > 0)
					str = "by " + likers.join() 
				document.getElementById(`picLikersList${data.picture_id}`).innerHTML += str;
			}
			
		})
		.catch(async (err) => 
		{
			console.error(err);
		})
}

async function getUser(host)
{
	let token = getCookie("token");
	if (token == "")
		return;
	let user = null;

	await fetch(`http://${host}:1337/user`, {
		method: 'POST',
		headers: {},
		body: JSON.stringify({token: token}),
	})
	.then((response) => {
		if (response.ok)
				return response.json();
			else
				return Promise.reject(response.json()); 
		})
	.then((data) => {
		user =  data;
	})
	.catch((e) => {})

	return user;
}