FROM dpdesi/todobackend-base:latest
MAINTAINER Duvane Deslandes <dpdeslandes@gmail.com>

# Copy application artifacts 
COPY target /wheelhouse

# Install application
RUN . /appenv/bin/activate && \
	pip install --no-index -f /wheelhouse todobackend && \
	rm -rf /wheelhouse
