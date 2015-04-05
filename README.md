7 reminder
===

About 7 reminder
---

7 reminder is a software which makes remembering vocabularies really easily. I used to use flash card applications. It was really helpful. But sometimes I got frustrated. So I try to develop a brand new software for this purpose. This is my hobby project with my friends. 

Now this apprication is not on production. I create this as a MVP and I create this for getting feedback from my friends. Which means, we might have a chance to rewrite this in the future.

What frustrate me the most?
---

### 1. Entry system

When I used a flash card application, I needed a bunch of time to entry new vocabularies. In addition, I'd like to store not only the meaning and example but also the context in which the word is used.

#### The goal of this software's entry system is like this.

You are reading an English articles on a website. You will find a word or expression which you didn't know. e.g. BBC, InfoQ, Bloomsberg... Then you just one click the word, this tool automatically entry the word with the definition, the sentence in which the word is used and the url of this site. This is not only English learning, you can use it for other languages learning as well.

### 2. Review system

When I reviewed using a flash card application, I could review only one word at the same time. I'd like to review 100 words per day at the same time. A flash card system has one-by-one review system. In addition, I add a lot of vocabularies everyday which means day-by-day review time will expand exponentially if you don't limit the entry of a day. But I need to record a lot of words and review more! 

Why I'd like to review 100 words per day at the same time? It is because I learnt a new methodology for memorizing something really effective. Once I used this , the result was magnificient. I was really bad at memorizing something, but now I have a confident to memorize something. e.g. Learning Chef quite quickly, memorizing over 1000 words only one month and English grammar only a week.

 I learnt this methodology from this article [Just 7 times reading makes me the No.1](http://president.jp/articles/-/11963)(Sorry, Japanese only) This woman graduates Tokyo university which is the highest ranking university in Japan. She kept no.1 during her school days using this strategy. 
 
  If she wants to memorize something, she just read the book 7 times. At the first and second times, she said that she can understand only 20-30%. but after reading 4-5 times, she can understand it exponentially and finally she can understand it thoughly and memorize it really good even if she is not trying to memorize it. 
  
  I try this several times. It always works for me to memorize something. 
  
  A knowledge for software, memorizing lyrics and so on. In the world of English learning in Japan, it is said that the best way to memorize vocabulary, just try to memorize 100 words in day 1st. You may not memorize perfectly at the first time, it could only 30% or higher. But it's OK. At the sencond day, you are going to memorize another 100 words. After 5-7 days you review the first 100 words, then another 100 words until you've reached 7 times. 

 The former CEO of google in japan, Mr. Murakami said in this book [Murakami's simple way to learn English](http://www.amazon.co.jp/%E6%9D%91%E4%B8%8A%E5%BC%8F%E3%82%B7%E3%83%B3%E3%83%97%E3%83%AB%E8%8B%B1%E8%AA%9E%E5%8B%89%E5%BC%B7%E6%B3%95-%E6%9D%91%E4%B8%8A-%E6%86%B2%E9%83%8E-ebook/dp/B0081MAET6/ref=dp_kinw_strp_1). 
 
```
 "Do you memorize only 10 words per day? It won't work. 
The thing is, review 10,000 words everyday. 
You don't need to memorize everything. Just read it. 
Believe me, it works."
```

These three strategies share one thing. "Review a lot at the same time and frequently." You don't worry about how you memorize/understand it at the first time. I try these strategy several times. It works perfectly for me.

That is why I need an application which has a brand new review system for me. Review one-by-one strategy is not good for me. I need to review a lot of words at the same time, frequently. 


#### The goal of this software would be like this.

Everyday, I review over 100 words per day. But it doesn't take a lot of time. Because I can review using list style review system that makes me  review a lot of words quite quickly. You can review whole words if you like even if it reaches 10,000 words like Mr. Murakami. 
 If I review a word I can mark it reviewed, which means I can record the number of reviews of the word. 

Since I'm not Mr. Murakami, so I choose the another option. I create review groups which contains a lot of words. The apprication reminds me reviewing using the groups until it reaches 7 times. 

Ops, I don't have a time to review today, but it's OK. I push the "Read them" button. Then this apprication read these loud. During my commute time, I can listen and review the vocabulary although it is really crowded. 

Today, I feel happy, so I'd like to take a pop quiz. Using list style, I can make sure if I can memorise a word or not. Since it is list style, I can check it out quite quickly. I don't care how I memorise it. The thing is just review a lot at the same time and review several times!



Features
---
* Entry a vocabulary with context (e.g. sentense and URL)
* One click entry system (Now on spiking, maybe we'll use chrome extension)
* List style review system
* Read the list loud system



For developers
---

* Ruby version  

```
2.2.0
```

* System dependencies 

```
I use MacBook Pro, yosemite
Virtual Box, Vagrant, DockerMachine and gems.
```

* Configuration

* Database creation

```
$ rake db:create
```

* Database initialization

```
$ rake db:migrate
$ rake db:migrate RAILS_ENV=test
```

* How to run the test suite

Rspec rails

```
$ rspec
```

Serverspec (tests for docker image)

```
$ docker image -t "serverspec_docker" .
$ rspec serverspec/xxxx.spec
```

* Services (job queues, cache servers, search engines, etc.)

```
TBD
```

* Deployment instructions

Local environment

```
$ bundle install
$ rake db:create
$ rake db:migrate
$ rake db:create RAILS_ENV=test
$ rake db:migrate RAILS_ENV=test
$ rails s
```

Production environment

```
TODO

I'm going to use docker-machine to deploy Azure cloud environment

```

### TODO

* Spike of one click entry system using chrome extension(Kaori)
* Database architecture (Now is experimental. Now using sqlite3 but I supporse we should use mysql or mongodb or something)
* User authentication
* Cool UI design. :)
