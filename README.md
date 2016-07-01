VIPerks Docker
==============

This project contains the images, container orchestration and development tools
for VIPerks API and APP services.

Dependencies
------------

VIPerks Docker works easiest with Kalabox, Docker Compose and NodeJS

  1. [Kalabox](https://github.com/kalabox/kalabox)
  2. [Docker Compose](https://docs.docker.com/compose/)
  3. [NodeJS](https://nodejs.org)

Installation
------------

```bash
# Get the VIPerks repo
git clone https://github.com/kalabox/viperks-docker.git
cd viperks-docker

# Only needed for running tests
npm install
```

Development
-----------

### Starting Services

```bash
# Start dev version of API service
cd api
kbox start
# Visit API at api.viperks.kbox

# Start dev version of APP service
cd app
kbox start
# Visit API at app.viperks.kbox

```

### Adding application code

@todo: Eventually this will be baked into the image itself

Here is an example with the api service.

```bash
# Start the dev api containers
cd api
kbox start

# Clone down your development source
cd code
kbox git clone https://location/of/api/repo
```

Testing
-------

We use Kalabox for easy testing. You will additionally need [node](http://nodejs.org) and
npm installed for this.

```bash
# Run all the tests
grunt test

# Run dev api tests
run test:apidev

# Run prod api tests
run test:apiprod

# Run dev app tests
run test:appdev

# Run dev app tests
run test:appprod
```

Production
----------

It's easiest to use Docker Compose to run your production stack. Note that
Docker Compose does not set up easy DNS like Kalabox does. Please also note
that you will need to make sure you have a docker engine set up and running
correctly before you do that.

```bash
# Run API
cd api
docker-compose -f kalabox-compose.yml up -d

# Run App
cd app
docker-compose -f kalabox-compose.yml up -d
```

