#!/usr/bin/env bats

#
# Local Dev Helpers
#

#
# If we are not on travis we want to emulate
# You will want to set these to values that make sense for your local setup although
# it probably makes the most sense to just do this
#
# before you run tests.
#

# Set some defaults if we are LOCAL
if [ ! $TRAVIS ]; then
  : ${TRAVIS_BUILD_DIR:=$(pwd)}
  : ${TRAVIS_COMMIT:=LOCAL}
fi

# Check to see if we are on Darwin
if [[ $(uname) == "Darwin" ]]; then
  : ${ON_OSX:=true}
else
  : ${ON_OSX:=false}
fi

#
# Kbox helpers
#

# Use `kbox.dev` if it exists, else use the normal `kbox` binary
: ${KBOX:=$(which kbox.dev || which kbox)}
: ${KBOX_APP_DIR:=$HOME/kbox_testing/apps}

#
# Docker helpers
#

# The "docker" binary, use `docker-machine ssh Kalabox2` on non-linux
if [ -f "$HOME/.kalabox/bin/docker-machine" ]; then
  : ${DOCKER:="$HOME/.kalabox/bin/docker-machine ssh Kalabox2 docker"}
else
  : ${DOCKER:="/usr/share/kalabox/bin/docker"}
fi

#
# Function to rety docker builds if they fail
#
kbox-retry-build() {

  # Get args
  IMAGE=$1
  TAG=$2
  DOCKERFILE=$3

  # Try a few times
  NEXT_WAIT_TIME=0
  until $DOCKER build -t $IMAGE:$TAG $DOCKERFILE || [ $NEXT_WAIT_TIME -eq 10 ]; do
    sleep $(( NEXT_WAIT_TIME++ ))
  done

  # If our final try has been met we assume failure
  #
  # @todo: this can be better since this could false negative
  #        on the final retry
  #
  if [ $NEXT_WAIT_TIME -eq 10 ]; then
    exit 666
  fi

}
