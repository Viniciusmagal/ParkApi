package com.mballem.demoparkapi.web.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.mballem.demoparkapi.repository.projection.ClienteVagaProjection;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class DashboardDto {
    private long totalVagas;
    private long vagasLivres;
    private long vagasOcupadas;
    private double taxaOcupacao;
    private long veiculosNoPatio;
    private long entradasHoje;
    private long saidasHoje;
    private BigDecimal faturamentoHoje;
    private BigDecimal faturamentoTotal;
    private long totalUsuarios;
    private long totalAdministradores;
    private long totalClientes;
    @Builder.Default
    private List<EntradasDia> entradasUltimos7Dias = new ArrayList<>();
    @Builder.Default
    private List<ClienteVagaProjection> ultimasMovimentacoes = new ArrayList<>();

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor
    public static class EntradasDia {
        @JsonFormat(pattern = "yyyy-MM-dd")
        private LocalDate dia;
        private long entradas;
    }
}
