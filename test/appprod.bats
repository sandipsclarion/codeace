#!/usr/bin/env bats

#
# Some tests to verify our docker images are built correctly and
# have the correct properties
#

# Load up environment
load env

#
# Setup some things
#
setup() {

  # Config
  VIPERKS_APP_ROOT="${TRAVIS_BUILD_DIR}/app"
  VIPERKS_APP_DOCKERFILES="${VIPERKS_APP_ROOT}/dockerfiles"
  VIPERKS_IMAGE_TAG=stable

  VIPERKS_PHP_VERSION=7.

  # Rename the kalabox compose override file so we don't load any dev
  # or local things
  mv "${VIPERKS_APP_ROOT}/kalabox-compose-override.yml" "${VIPERKS_APP_ROOT}/kalabox-compose-override.hidden.yml"

}

#
# Check that we can build the nginx image without an error.
#
@test "Check that we can build the web image without an error." {
  run kbox-retry-build viperks/web app-$VIPERKS_IMAGE_TAG $VIPERKS_APP_DOCKERFILES/web
  [ "$status" -eq 0 ]
}

#
# Check that we can build the app image without an error.
#
@test "Check that we can build the app image without an error." {
  run kbox-retry-build viperks/app $VIPERKS_IMAGE_TAG $VIPERKS_APP_DOCKERFILES/app
  [ "$status" -eq 0 ]
}

#
# Check that we can build the db image without an error.
#
@test "Check that we can build the db image without an error." {
  run kbox-retry-build viperks/db $VIPERKS_IMAGE_TAG $VIPERKS_APP_DOCKERFILES/db
  [ "$status" -eq 0 ]
}

#
# Check that we can build the redis image without an error.
#
@test "Check that we can build the redis image without an error." {
  run kbox-retry-build viperks/redis $VIPERKS_IMAGE_TAG $VIPERKS_APP_DOCKERFILES/redis
  [ "$status" -eq 0 ]
}

#
# Check that the APP image has the correct PHP version.
#
@test "Check that the APP image has the correct PHP version." {
  run $DOCKER run viperks/app:$VIPERKS_IMAGE_TAG php-fpm --version
  [ "$status" -eq 0 ]
  [[ $output == *"$VIPERKS_PHP_VERSION"* ]]
}

#
# Check that the APP image has the correct PHP extensions.
#
@test "Check that the APP image has the correct PHP extensions." {
  $DOCKER run viperks/app:$VIPERKS_IMAGE_TAG php-fpm -m | grep "curl" && \
  $DOCKER run viperks/app:$VIPERKS_IMAGE_TAG php-fpm -m | grep "pdo_mysql" && \
  $DOCKER run viperks/app:$VIPERKS_IMAGE_TAG php-fpm -m | grep "redis" && \
  $DOCKER run viperks/app:$VIPERKS_IMAGE_TAG php-fpm -m | grep "Zend OPcache"
}

#
# Check that the APP image has phpunit installed.
#
@test "Check that the APP image has phpunit installed." {
  run $DOCKER run viperks/app:$VIPERKS_IMAGE_TAG phpunit --version
  [ "$status" -eq 0 ]
}

#
# Check that we can spin up the site in kalabox.
#
@test "Check that we can spin up the site in kalabox." {
  cd "$VIPERKS_APP_ROOT"
  run kbox start
  [ "$status" -eq 0 ]
}

#
# Check that the db container exists and is in the correct state.
#
@test "Check that the db container exists and is in the correct state." {
  $DOCKER inspect appviperks_db_1 | grep "\"Status\": \"running\""
}

#
# Check that the redis container exists and is in the correct state.
#
@test "Check that the redis container exists and is in the correct state." {
  $DOCKER inspect appviperks_redis_1 | grep "\"Status\": \"running\""
}

#
# Check that the app container exists and is in the correct state.
#
@test "Check that the app container exists and is in the correct state." {
  $DOCKER inspect appviperks_app_1 | grep "\"Status\": \"running\""
}

#
# Check that the web container exists and is in the correct state.
#
@test "Check that the web container exists and is in the correct state." {
  $DOCKER inspect appviperks_web_1 | grep "\"Status\": \"running\""
}

#
# Check that the PROD API container does not have the xdebug extension enabled.
#
@test "Check that the PROD API container does not have the xdebug extension enabled." {
  run $DOCKER exec appviperks_app_1 php-fpm -m
  [[ $output != *"xdebug"* ]]
}

#
# Check that the web image has a link to the app.
#
@test "Check that the web image has a link to the api." {
  $DOCKER exec appviperks_web_1 cat /etc/hosts | grep "app"
}

#
# Check that the APP image has the correct links to redis and mysql.
#
@test "Check that the APP image has the correct links to redis and mysql." {
  $DOCKER exec appviperks_app_1 cat /etc/hosts | grep "database" && \
  $DOCKER exec appviperks_app_1 cat /etc/hosts | grep "redis"
}

#
# BURN IT TO THE GROUND!!!!
# Add a small delay before we run other things
#
teardown() {

  # Take a little break
  sleep 1

  # Rename the kalabox compose override file back so we are in the same
  # state we started in
  mv "${VIPERKS_APP_ROOT}/kalabox-compose-override.hidden.yml" "${VIPERKS_APP_ROOT}/kalabox-compose-override.yml"

}
