FROM vborja/asdf-alpine

RUN /bin/bash -c " \
        source $HOME/.asdf/asdf.sh && \
        asdf plugin-add alp https://github.com/asdf-community/asdf-alp.git && \
        asdf install alp 1.0.15 && asdf global alp 1.0.15 \
    "

CMD ["alp", "--help"]