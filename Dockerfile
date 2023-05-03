FROM debian:stable-slim as base

# Basics 
RUN mkdir /scripts

# Install packages
COPY sys-packages-build.txt /scripts
COPY scripts/install-packages.sh /scripts
RUN /scripts/install-packages.sh build

# Install conda
COPY scripts/install-conda.sh /scripts
RUN /scripts/install-conda.sh

# Conda path
ENV PATH /opt/conda/bin:$PATH
# Setup locale. This prevents Python 3 IO encoding issues.
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
# Make stdout/stderr unbuffered. This prevents delay between output and cloud
# logging collection.
ENV PYTHONUNBUFFERED 1

# Create the python env using conda
COPY environment.txt /scripts
COPY scripts/create-env.sh /scripts
RUN /scripts/create-env.sh

# Install all requirements
COPY requirements.txt /scripts
COPY scripts/install-requirements.sh /scripts
RUN /scripts/install-requirements.sh

################################################################################################################
# Start a new docker base

# Copy only the env from last
FROM debian:stable-slim
COPY --from=base /opt/conda/envs/py311 /env

# Basics 
RUN mkdir /scripts

# Install packages
COPY sys-packages-runtime.txt /scripts
COPY scripts/install-packages.sh /scripts
RUN /scripts/install-packages.sh runtime

# Conda path
ENV PATH /env/bin:$PATH

# Setup the app working directory
RUN mkdir -p /app
WORKDIR /app

# Port 8080 is the port used by Google App Engine for serving HTTP traffic.
EXPOSE 8080
ENV PORT 8080

# The user's Dockerfile must specify an entrypoint with ENTRYPOINT or CMD.
COPY *.sh /scripts
COPY scripts/start.sh /scripts
ENTRYPOINT ["/scripts/start.sh"]
