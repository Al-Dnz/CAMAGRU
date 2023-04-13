import { getHost, getCookie} from '../config.js';
import createCommentBox from './commentBox.js';



function createCard(picture) {
	const markup =
		`<div id="pictureCard${picture.id}" style="display: block" class="max-w-sm max-w-md mx-auto rounded overflow-hidden shadow-lg" data-type="picture_card_template">
			<div class="flex justify-between">
				<div class="flex justify-start">
					<div class="font-bold text-xl mb-2">${picture.user}</div>
				</div>

				<div class="flex justify-end">
					<div class="text-xl text-gray-400">${new Date(picture.published_date).toLocaleString()}</div>

					<button id="deleteCardBtn${picture.id}" type="button" class="ml-5 bg-indigo-400  rounded-md inline-flex items-center justify-center text-white hover:text-gray-500 hover:bg-gray-100 focus:outline-none  ">
						<span class="sr-only">Close menu</span>
						<svg class="h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
						</svg>
					</button>
				</div>
			</div>
			<img class="w-full" src="${picture.path}">
			<div class="px-6 py-3 flex flex-row ">
				<button class="pr-3 pb-7" id="pictureCardLike${picture.id}" activated=false>
					<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5 ">
						<path stroke-linecap="round" stroke-linejoin="round" d="M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12z" />
					</svg>
				</button>
				<br/>
				<div id="picLikersList${picture.id}" class="overflow-x-auto pb-7 font-bold">
				</div>
			</div>
			<div class="px-6 pt-4 pb-2  space-y-4 comments overflow-y-auto h-32"> </div>
			<div class="px-6 pb-2">
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



