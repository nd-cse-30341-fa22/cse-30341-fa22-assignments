# To Build: docker build --no-cache -t pbui/cse-30341-fa22-assignments . < Dockerfile

FROM        ubuntu:22.04
MAINTAINER  Peter Bui <pbui@nd.edu>

RUN         apt-get update -y

# Run-time dependencies
RUN         apt-get install -y python3-tornado python3-requests python3-yaml python3-markdown

# Shell utilities
RUN	    apt-get install -y curl bc netcat iproute2 zip unzip gawk

# Language Support: C, C++, Make, valgrind, cppcheck
RUN         apt-get install -y gcc g++ make valgrind cppcheck libssl-dev
