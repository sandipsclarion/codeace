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
  VIPERKS_API_ROOT="${TRAVIS_BUILD_DIR}/api"
  VIPERKS_API_DOCKERFILES="${VIPERKS_API_ROOT}/dockerfiles"
  VIPERKS_IMAGE_TAG=latest

  VIPERKS_PHP_VERSION=7.

}

#
# Check that we can build the data image without an error.
#
@test "Check that we can build the data image without an error." {
  run kbox-retry-build busybox latest $VIPERKS_API_DOCKERFILES/data
  [ "$status" -eq 0 ]
}

#
# Check that we can build the nginx image without an error.
#
@test "Check that we can build the web image without an error." {
  run kbox-retry-build viperks/web api-$VIPERKS_IMAGE_TAG $VIPERKS_API_DOCKERFILES/web
  [ "$status" -eq 0 ]
}

#
# Check that we can build the api image without an error.
#
@test "Check that we can build the api image without an error." {
  run kbox-retry-build viperks/api $VIPERKS_IMAGE_TAG $VIPERKS_API_DOCKERFILES/api
  [ "$status" -eq 0 ]
}

#
# Check that the API image has the correct PHP version.
#
@test "Check that the API image has the correct PHP version." {
  run $DOCKER run viperks/api:$VIPERKS_IMAGE_TAG php-fpm --version
  [ "$status" -eq 0 ]
  [[ $output == *"$VIPERKS_PHP_VERSION"* ]]
}

#
# Check that the API image has the correct PHP extensions.
#
@test "Check that the API image has the correct PHP extensions." {
  $DOCKER run viperks/api:$VIPERKS_IMAGE_TAG php-fpm -m | grep "curl" && \
  $DOCKER run viperks/api:$VIPERKS_IMAGE_TAG php-fpm -m | grep "imagick" && \
  $DOCKER run viperks/api:$VIPERKS_IMAGE_TAG php-fpm -m | grep "pdo_mysql" && \
  $DOCKER run viperks/api:$VIPERKS_IMAGE_TAG php-fpm -m | grep "Zend OPcache"
}

#
# Check that the API image has composer installed.
#
@test "Check that the API image has composer installed." {
  run $DOCKER run viperks/api:$VIPERKS_IMAGE_TAG composer
  [ "$status" -eq 0 ]
}

#
# Check that the API image has phpunit installed.
#
@test "Check that the API image has phpunit installed." {
  run $DOCKER run viperks/api:$VIPERKS_IMAGE_TAG phpunit --version
  [ "$status" -eq 0 ]
}

#
# Check that we can spin up the site in kalabox.
#
@test "Check that we can spin up the site in kalabox." {
  cd "$VIPERKS_API_ROOT"
  run kbox start
  [ "$status" -eq 0 ]
}

#
# Check that the data container exists and is in the correct state.
#
@test "Check that the data container exists and is in the correct state." {
  $DOCKER inspect apiviperks_data_1 | grep "\"Status\": \"exited\""
}

#
# Check that the api container exists and is in the correct state.
#
@test "Check that the api container exists and is in the correct state." {
  $DOCKER inspect apiviperks_api_1 | grep "\"Status\": \"running\""
}

#
# Check that the web container exists and is in the correct state.
#
@test "Check that the web container exists and is in the correct state." {
  $DOCKER inspect apiviperks_web_1 | grep "\"Status\": \"running\""
}

#
# Check that the DEV API container has the xdebug extension enabled.
#
@test "Check that the DEV API container has the xdebug extension enabled." {
  $DOCKER exec apiviperks_api_1 php-fpm -m | grep xdebug
}

#
# Check that the web image has a link to the api.
#
@test "Check that the web image has a link to the api." {
  $DOCKER exec apiviperks_web_1 cat /etc/hosts | grep "api"
}

#
# BURN IT TO THE GROUND!!!!
# Add a small delay before we run other things
#
teardown() {
  sleep 1
}
