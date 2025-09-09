/*swipers["slider"].update();
$(document).ready(function(){
 new Swiper('.swiper', {
        slidesPerView: 1,
        loop: true,
		speed: 1200,
		autoplay: {
			delay: 3000,
		},
        pagination: {
			clickable: true,
            el: '.swiper-pagination',
        },
		freemode: {
			enabled: true
		},
        navigation: {
            nextEl: '.swiper-button-next',
            prevEl: '.swiper-button-prev',
        },
        // 'xs': '475px',
        // 'sm': '640px',
        // 'md': '768px',
        // 'lg': '1024px',
        // 'xl': '1280px',
        // '2xl': '1536px',
        breakpoints: {
            1024: {
              slidesPerView: 2
            },
          }
    });
})
*/

function generateSwippers() {
    new Swiper('.swiper', {
        slidesPerView: 1,
        loop: true,
		speed: 1200,
		autoplay: {
			delay: 3000,
		},
        pagination: {
			clickable: true,
            el: '.swiper-pagination',
        },
		freemode: {
			enabled: true
		},
        navigation: {
            nextEl: '.swiper-button-next',
            prevEl: '.swiper-button-prev',
        },
        // 'xs': '475px',
        // 'sm': '640px',
        // 'md': '768px',
        // 'lg': '1024px',
        // 'xl': '1280px',
        // '2xl': '1536px',
        breakpoints: {
            640: {
              slidesPerView: 2
            },
            768: {
              slidesPerView: 3
            },
            1024: {
              slidesPerView: 4
            },
            1280: {
              slidesPerView: 5
            },
          }
    });
}
$(document).ready(function() {
    // Initialize Swiper on document ready
    generateSwippers();
});
