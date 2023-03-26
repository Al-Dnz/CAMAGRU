import { getHost, getCookie} from '../config.js';
import createCommentBox from './commentBox.js';



function createCard(picture) {
	const markup =
		`<div id="pictureCard${picture.id}" style="display: block" class="max-w-sm max-w-md mx-auto rounded overflow-hidden shadow-lg" data-type="picture_card_template">
			<div class="font-bold text-xl mb-2">${picture.user}</div>
			<img class="w-full" src="${picture.path}">
			<div class="px-6 py-4">
				<button>
					<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5 text-red-500 fill-red-500">
						<path stroke-linecap="round" stroke-linejoin="round" d="M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12z" />
					</svg>
				</button>
				<br/>
				<hr/>
				<p class="text-gray-700 text-base"> ${picture.content} </p>
			</div>
			<div class="px-6 pt-4 pb-2  space-y-4 comments overflow-y-auto h-32"> </div>
			<div class="px-6 pt-4 pb-2">
				<form class=" inline-block mt-3  flex   flex-row   flex-wrap" action="" method="">
					<div class="text-gray-600  w-3/4">
						<input id="inputComment${picture.id}" type="text" name="comment" class=" w-full p-2 rounded-l-lg" placeholder="Your comment"/>
					</div>
					<div class=" w-1/4">
						<button id="sendComment${picture.id}" class=" w-full text-white  p-2  bg-indigo-400  rounded-r-lg text-center hover: bg-indigo-300" type="button">Send</button>
					</div>
				</form>
				
			</div>
		</div>`

	let div = document.createElement("div");
	div.innerHTML = markup;
	return div;
}


export { createCard as default };



