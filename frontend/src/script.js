import { getHost, getCookie, getPartial } from '../config.js';
import { setNavbar } from '../navbar/navbar.js';
import createCard from './components/pictureCard.js';
import createCommentBox from './components/commentBox.js';

document.addEventListener("DOMContentLoaded", async function(event) { 
	
	const range = 5;
	const host = await getHost("./config.json");
	await getPartial('navbar', '../navbar/navbar.html').then(()=> { setNavbar() })
	const user  = await getUser(host);
	await setPagination(user, host, range);
	await getPictures(host, 1, range, user);
	await getLikes(user, host);
	await getComments(host);
});

function createPaginationNumberItem(user, host, page_number, range)
{
	let li = document.createElement("li");
	li.setAttribute("id", `page${page_number}`);
	let classArray =  ["px-3", "py-2", "leading-tight", "text-gray-500", "bg-white", "border", "border-gray-300", "hover:bg-gray-100", "hover:text-gray-700", "dark:bg-gray-800", "dark:border-gray-700", "dark:text-gray-400", "dark:hover:bg-gray-700", "dark:hover:text-white"];
	for (let classItem of classArray)
		li.classList.add(classItem);
	li.innerHTML = page_number;
	li.addEventListener("click", async (event) => {
		await getPictures(host, page_number, range, user);
		await getLikes(user, host);
		await getComments(host);
	});
	return li;
}

async function setPagination(user, host, range)
{
	const ul = document.getElementById("pageSelectBtnList");
	await fetch(`http://${host}:1337/data`)
	.then((response) => response.json())
	.then((data) => 
	{
		let numberOfDatas =  data.length
		for (let i  = 1 ; i <= 1 + numberOfDatas / range; i++)
		{
			let li = createPaginationNumberItem(user, host, i, range);
			ul.appendChild(li);
		}
	})
}

async function getPictures(host, pageNumber, range, user)
{
	const list =  document.getElementById("dataList");
	list.innerHTML = "";

	await fetch(`http://${host}:1337/data`)
	.then((response) => response.json())
	.then((data) => 
	{
		data = data.reverse();
		let i = 0;
		for (let el of data)
		{	
			i++;
			if (i <= (pageNumber - 1) * range)
				continue;
			if (i > pageNumber  * range)
				break;

			var item = createCard(el);
			list.appendChild(item);
			list.appendChild(document.createElement("br"));
			const sendBtn = document.getElementById(`sendComment${el.id}`);
			const comment = document.getElementById(`inputComment${el.id}`);
			sendBtn.addEventListener("click", () => { postComment(host, comment, el.id) });
			const likeBtn = document.getElementById(`pictureCardLike${el.id}`);
			likeBtn.addEventListener("click", async () => { await pictureCardLikeHandler(host, el.id) });
			const deleteCardBtn = document.getElementById(`deleteCardBtn${el.id}`);
			if (user && el.user == user.login)
				deleteCardBtn.addEventListener("click", async () => { await  deletePicture(host, el.id) });
			else
				deleteCardBtn.remove();
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
			if (divId == null)
				continue;	
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
		let divId = `pictureCard${res.picture_id}`;
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
			let picUsers = {}
			for(let data of res)
			{
				if (!(parseInt(data.picture_id, 10) in picUsers))
					picUsers[parseInt(data.picture_id, 10)] = [];
				let likeBtn = document.getElementById(`pictureCardLike${data.picture_id}`);
				if (!likeBtn)
					continue;
				if (user && data.user_id == user.id)
				{
					likeBtn.setAttribute('activated', `${true}`);
					likeBtn.querySelector('svg').classList.add('text-red-500');
					likeBtn.querySelector('svg').classList.add('fill-red-500');
				}
				else
					picUsers[parseInt(data.picture_id, 10)].push(data.user)
			}
			for (let picId of Object.keys(picUsers))
			{
				let str = "by " + picUsers[`${picId}`].join(', ')
				let div = document.getElementById(`picLikersList${picId}`);
				if (div)
					div.innerHTML = str;
			}
			
		})
		.catch(async (err) => 
		{
			err = await err;
			console.error(err);
		})
}

async function getUser(host)
{
	let user = null;
	let token = getCookie("token");
	if (token == "")
		return user;
	

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


async function deletePicture(host, pictureId)
{
	let token = getCookie("token");
	if (token == "")
		return;
	
	const data = 
	{
		token: token,
		picture_id:  parseInt(pictureId, 10)
	}
	await fetch(`http://${host}:1337/delete_picture`,
		{
			method: 'POST',
			headers: {},
			body: JSON.stringify(data)
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
			const deleteCardBtn = document.getElementById(`pictureCard${pictureId}`);
			deleteCardBtn.remove();
		})
		.catch(async (err) => 
		{
			err = await err;
			console.error(err);
		})
}