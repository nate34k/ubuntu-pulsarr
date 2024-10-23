FROM kasmweb/core-ubuntu-focal:1.16.0
USER root
ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########
# Install audio tools and cargo
RUN apt-get update && apt-get install -y \
    flac \
    lame \
    ffmpeg \
    sox
    
# Install Brave Browser
RUN apt-get install -y apt-transport-https curl && \
    curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list && \
    apt-get update && \
    apt-get install -y brave-browser

# Configure Brave to run in container
RUN mkdir -p /etc/brave && \
    echo '{"sandbox": false}' > /etc/brave/sandbox.conf && \
    echo '#!/bin/bash\nexec /usr/bin/brave-browser --no-sandbox "$@"' > /usr/bin/brave-safe && \
    chmod +x /usr/bin/brave-safe

# Update the startup script
RUN echo "/usr/bin/desktop_ready && brave-safe &" > $STARTUPDIR/custom_startup.sh \
    && chmod +x $STARTUPDIR/custom_startup.sh

######### End Customizations ###########
RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME
ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME
USER 1000
