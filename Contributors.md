# Instructions for contributors

Prepare your dev env by setting the environment variables:

```
$ cp env.sample.sh env.sample
$ vim env.sh # change it to your needs
$ . ./env.sh # will load your dev env vars.
```

I miss Pry when I'm on [Rubinius](http://rubini.us/), so I do write the code on MRI and test on Rubinius once in a while. You will find that [Travis](https://travis-ci.org/) is your friend.
