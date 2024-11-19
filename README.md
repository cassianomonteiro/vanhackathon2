# vanhackathon2
This project was performed during the VanHackathon 2.0 (October 2016). The goal was to develop an MVP to on two challenges:

* Dreamify's Dream Feed: propose a feed concept that is different from pinterest, facebook, twitter or instagram.
* Shopify's The Future of Commerce: create a project that represents The Future of Commerce.

## The idea
Thinking about the idea of diversify social networks feeds, and also accounting for Dreamify's dream concept, we thought of linking together into a feed entry everything related to a dream's accomplishment.
Therefore, a user could post any kind of media relative to the dream, such as photos, videos, songs, etc.
And all media would compose one single feed entry, and looking at this feed should make the user feel the dream.

So, for accomplishing that dream, the user might need some products and/or services as well. Products and services could also be part of a dream entry on the feed, where users could add them as a wish list, for buying in any point in the future as part of the dream accomplishment. 
Furthermode, this could start some sort of donations and crowdfunding, where other people on the network could contribute for buying stuff needed for the dream.

This is where Shopify comes in! With its large network of vendors, Shopify could integrate on the dreams needs, so users could search for stuff on any shops in Shopify's platform, and also Shopify could advertise products that are related to users dreams!
This is what we see as the future of commerce, where target audiences are even more specific, and can be achieved through social networks, generating higher conversion.

## The project
To illustrate our idea, we developed an MVP app for Android/iOS where a user can log in, see the dreams feed and post dreams to the feed.
For creating dreams, the user can post photos, youtube videos and products from Shopify. Also, form the feed, a user could directly buy products, following the shopping flow to the end of checkout.

To accomplish this, we used the following main technologies:
* Google Firebase Auth and storage (for user's pictures)
* Shopify API for products search and buy
* Youtube API for videos
* Heroku+PostgresSQL for our social network structure backend (to glue everything)

## The product
The following products were delivered at the end of the Hackathon:
* iOS app (this repository)
* Android app: https://github.com/jrvansuita/DreamShop
* Backend API: https://github.com/taylorrf/dreamwishlist_api
* Backend API documentation: https://dreamwishlist-api.herokuapp.com
* iOS sample video: https://youtu.be/21728hNrxsI
* Android sample video: https://youtu.be/8aYSKTKC4gY

## Personal achievement
I was very happy and excited about participating on this virtual hackathon. I had never been to a hackathon before, and I was really surprised on what I could deliver within those 48 hours.
So, after 40 hours of programming with only 4 hours of sleep in between, I got a really nice MVP app with nearly 8k LOC, and lot's of learning.

In fact, those are the topics that I had never done before and I had to lear fast during the Hackathon:
* Access Photo Library and Camera, and deal with images resizing
* Integrate with Google Firebase Auth and Storage APIs
* Access and parse REST API on the standards presented on jsonapi.org
* Integrate to Shopify SDK to access shops and shopping flow to checkout
* Integrate MagicalRecord and RestKit frameworks to work together on the same ManagedObjectContext

## In the end of the day
I feel great! It was awesome to work with the team, even remotely! We didn't think we would able to to everything we wanted, but it actually came up just fine!

Thanks guys!
