package com.mballem.demoparkapi.web.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class DisponibilidadeDto {
    private long total;
    private long livres;
    private long ocupadas;
}
