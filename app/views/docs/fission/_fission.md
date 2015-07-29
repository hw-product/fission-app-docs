# Getting Started {#getting-started}

# Features

## Custom Services

Custom services are remote services that can be used suppliment existing
services to provide expanded functionality. Once registered, these services
can be used within a pipeline's route composition.

### How it works

Steps taken when a custom service is reached within a pipeline's route:

1. Job payload is `POST`ed to the registered endpoint
2. Remote service performs action(s)
3. Payload is `POST`ed to return endpoint

### Creating a custom service

The `shortorder` program can assist in creating a custom service. First,
install the gem:

```ruby
$ gem install shortorder
```

Create a new custom service:

```ruby
$ shortoder custom-service stub
```

### Using local running services

Due to networking constraints that may prevent a locally running custom
service to be available, using a helper service like [ngrok](http://ngrok.com).
