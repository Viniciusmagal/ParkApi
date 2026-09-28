package com.mballem.demoparkapi.web.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.*;
import org.hibernate.validator.constraints.br.CPF;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class SolicitacaoVagaDto {
    @Size(max = 100, message = "{Size.solicitacaoVagaDto.nome}")
    private String nome;
    @CPF(message = "{CPF.solicitacaoVagaDto.cpf}")
    private String cpf;
    @NotBlank(message = "{NotBlank.solicitacaoVagaDto.placa}")
    @Pattern(regexp = "^([A-Za-z]{3}-[0-9]{4}|[A-Za-z]{3}[0-9][A-Za-z][0-9]{2})$",
            message = "{Pattern.solicitacaoVagaDto.placa}")
    private String placa;
    @NotBlank(message = "{NotBlank.solicitacaoVagaDto.marca}")
    @Size(max = 45)
    private String marca;
    @NotBlank(message = "{NotBlank.solicitacaoVagaDto.modelo}")
    @Size(max = 45)
    private String modelo;
    @NotBlank(message = "{NotBlank.solicitacaoVagaDto.cor}")
    @Size(max = 45)
    private String cor;
}
