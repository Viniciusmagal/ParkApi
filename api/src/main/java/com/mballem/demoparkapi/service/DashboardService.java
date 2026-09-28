package com.mballem.demoparkapi.service;

import com.mballem.demoparkapi.entity.ClienteVaga;
import com.mballem.demoparkapi.entity.Usuario;
import com.mballem.demoparkapi.repository.ClienteRepository;
import com.mballem.demoparkapi.repository.ClienteVagaRepository;
import com.mballem.demoparkapi.repository.UsuarioRepository;
import com.mballem.demoparkapi.web.dto.DashboardDto;
import com.mballem.demoparkapi.web.dto.DisponibilidadeDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@RequiredArgsConstructor
@Service
public class DashboardService {

    private final VagaService vagaService;
    private final ClienteVagaRepository clienteVagaRepository;
    private final UsuarioRepository usuarioRepository;
    private final ClienteRepository clienteRepository;

    @Transactional(readOnly = true)
    public DashboardDto gerar() {
        DisponibilidadeDto disponibilidade = vagaService.buscarDisponibilidade();
        LocalDateTime inicioDoDia = LocalDate.now().atStartOfDay();
        double taxa = disponibilidade.getTotal() == 0 ? 0
                : Math.round(disponibilidade.getOcupadas() * 1000.0 / disponibilidade.getTotal()) / 10.0;

        return DashboardDto.builder()
                .totalVagas(disponibilidade.getTotal())
                .vagasLivres(disponibilidade.getLivres())
                .vagasOcupadas(disponibilidade.getOcupadas())
                .taxaOcupacao(taxa)
                .veiculosNoPatio(clienteVagaRepository.countByDataSaidaIsNull())
                .entradasHoje(clienteVagaRepository.countByDataEntradaGreaterThanEqual(inicioDoDia))
                .saidasHoje(clienteVagaRepository.countByDataSaidaGreaterThanEqual(inicioDoDia))
                .faturamentoHoje(clienteVagaRepository.somarFaturamentoDesde(inicioDoDia))
                .faturamentoTotal(clienteVagaRepository.somarFaturamentoTotal())
                .totalUsuarios(usuarioRepository.count())
                .totalAdministradores(usuarioRepository.countByRole(Usuario.Role.ROLE_ADMIN))
                .totalClientes(clienteRepository.count())
                .entradasUltimos7Dias(entradasUltimos7Dias())
                .ultimasMovimentacoes(clienteVagaRepository.findTop8ByOrderByDataModificacaoDesc())
                .build();
    }

    private List<DashboardDto.EntradasDia> entradasUltimos7Dias() {
        LocalDate hoje = LocalDate.now();
        LocalDate inicio = hoje.minusDays(6);
        Map<LocalDate, Long> porDia = clienteVagaRepository
                .findAllByDataEntradaGreaterThanEqual(inicio.atStartOfDay())
                .stream()
                .map(ClienteVaga::getDataEntrada)
                .map(LocalDateTime::toLocalDate)
                .collect(Collectors.groupingBy(Function.identity(), Collectors.counting()));

        List<DashboardDto.EntradasDia> dias = new ArrayList<>();
        for (LocalDate dia = inicio; !dia.isAfter(hoje); dia = dia.plusDays(1)) {
            dias.add(new DashboardDto.EntradasDia(dia, porDia.getOrDefault(dia, 0L)));
        }
        return dias;
    }
}
