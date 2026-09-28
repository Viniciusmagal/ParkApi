package com.mballem.demoparkapi.web.controller;

import com.mballem.demoparkapi.service.DashboardService;
import com.mballem.demoparkapi.web.dto.DashboardDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Dashboard", description = "Indicadores gerais do estacionamento")
@RequiredArgsConstructor
@RestController
@RequestMapping("api/v1/dashboard")
public class DashboardController {

    private final DashboardService dashboardService;

    @Operation(summary = "Indicadores do painel administrativo",
            description = "Vagas, ocupação, movimentação do dia, faturamento e usuários. Acesso restrito a Role='ADMIN'",
            security = @SecurityRequirement(name = "security"))
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<DashboardDto> getDashboard() {
        return ResponseEntity.ok(dashboardService.gerar());
    }
}
