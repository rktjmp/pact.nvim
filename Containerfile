FROM debian

# Install dependencies
RUN apt-get update -y && \
  apt-get install -y curl git

# Install neovim
WORKDIR /tmp
RUN curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz
RUN tar xzf nvim-linux64.tar.gz -C /opt
ENV PATH /opt/nvim-linux64/bin:$PATH

WORKDIR /root/.config/nvim/
RUN curl -LO https://raw.githubusercontent.com/rktjmp/pact.nvim/master/container/init.lua

WORKDIR /root
CMD bash -c 'nvim +"lua require\"pact\".open({win=0,buf=0})"; exec bash'
