package com.mballem.demoparkapi.service;

import com.mballem.demoparkapi.entity.Cliente;
import com.mballem.demoparkapi.entity.ClienteVaga;
import com.mballem.demoparkapi.entity.Vaga;
import com.mballem.demoparkapi.exception.SolicitacaoVagaException;
import com.mballem.demoparkapi.util.EstacionamentoUtils;
import com.mballem.demoparkapi.web.dto.SolicitacaoVagaDto;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@RequiredArgsConstructor
@Service
public class EstacionamentoService {

    private final ClienteVagaService clienteVagaService;
    private final ClienteService clienteService;
    private final VagaService vagaService;

    @Transactional
    public ClienteVaga checkIn(ClienteVaga clienteVaga) {
        Cliente cliente = clienteService.buscarPorCpf(clienteVaga.getCliente().getCpf());
        return registrarEntrada(clienteVaga, cliente);
    }

    @Transactional
    public ClienteVaga solicitarVaga(Long usuarioId, SolicitacaoVagaDto dto) {
        Cliente cliente = clienteService.buscarOuCriarParaUsuario(usuarioId, dto.getNome(), dto.getCpf());

        if (clienteVagaService.existeAtivoPorCliente(cliente.getId())) {
            throw new SolicitacaoVagaException("exception.solicitacao.clienteAtivo", HttpStatus.CONFLICT);
        }

        String placa = dto.getPlaca().trim().toUpperCase();
        if (clienteVagaService.existeAtivoPorPlaca(placa)) {
            throw new SolicitacaoVagaException("exception.solicitacao.placaAtiva", HttpStatus.CONFLICT, placa);
        }

        ClienteVaga clienteVaga = new ClienteVaga();
        clienteVaga.setPlaca(placa);
        clienteVaga.setMarca(dto.getMarca().trim());
        clienteVaga.setModelo(dto.getModelo().trim());
        clienteVaga.setCor(dto.getCor().trim());
        return registrarEntrada(clienteVaga, cliente);
    }

    @Transactional
    public ClienteVaga checkOut(String recibo) {
        ClienteVaga clienteVaga = clienteVagaService.buscarPorRecibo(recibo);

        LocalDateTime dataSaida = LocalDateTime.now();

        BigDecimal valor = EstacionamentoUtils.calcularCusto(clienteVaga.getDataEntrada(), dataSaida);
        clienteVaga.setValor(valor);

        long totalDeVezes = clienteVagaService.getTotalDeVezesEstacionamentoCompleto(clienteVaga.getCliente().getCpf());

        BigDecimal desconto = EstacionamentoUtils.calcularDesconto(valor, totalDeVezes);
        clienteVaga.setDesconto(desconto);

        clienteVaga.setDataSaida(dataSaida);
        clienteVaga.getVaga().setStatus(Vaga.StatusVaga.LIVRE);

        return clienteVagaService.salvar(clienteVaga);
    }

    private ClienteVaga registrarEntrada(ClienteVaga clienteVaga, Cliente cliente) {
        clienteVaga.setCliente(cliente);

        Vaga vaga = vagaService.buscarPorVagaLivre();
        vaga.setStatus(Vaga.StatusVaga.OCUPADA);
        clienteVaga.setVaga(vaga);

        clienteVaga.setDataEntrada(LocalDateTime.now());

        clienteVaga.setRecibo(EstacionamentoUtils.gerarRecibo());

        return clienteVagaService.salvar(clienteVaga);
    }
}
