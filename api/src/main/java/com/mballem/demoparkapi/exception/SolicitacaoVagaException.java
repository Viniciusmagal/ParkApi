package com.mballem.demoparkapi.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public class SolicitacaoVagaException extends RuntimeException {

    private final String codigoMensagem;
    private final HttpStatus status;
    private final Object[] parametros;

    public SolicitacaoVagaException(String codigoMensagem, HttpStatus status, Object... parametros) {
        super(codigoMensagem);
        this.codigoMensagem = codigoMensagem;
        this.status = status;
        this.parametros = parametros;
    }
}
