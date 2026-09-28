package com.mballem.demoparkapi.service;

import com.mballem.demoparkapi.entity.ClienteVaga;
import com.mballem.demoparkapi.exception.ReciboCheckInNotFoundException;
import com.mballem.demoparkapi.repository.ClienteVagaRepository;
import com.mballem.demoparkapi.repository.projection.ClienteVagaProjection;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@RequiredArgsConstructor
@Service
public class ClienteVagaService {

    private final ClienteVagaRepository repository;

    @Transactional
    public ClienteVaga salvar(ClienteVaga clienteVaga) {
        return repository.save(clienteVaga);
    }

    @Transactional(readOnly = true)
    public ClienteVaga buscarPorRecibo(String recibo) {
        return repository.findByReciboAndDataSaidaIsNull(recibo).orElseThrow(
                () -> new ReciboCheckInNotFoundException(recibo)
        );
    }

    @Transactional(readOnly = true)
    public long getTotalDeVezesEstacionamentoCompleto(String cpf) {
        return repository.countByClienteCpfAndDataSaidaIsNotNull(cpf);
    }

    @Transactional(readOnly = true)
    public Page<ClienteVagaProjection> buscarTodosPorClienteCpf(String cpf, Pageable pageable) {
        return repository.findAllByClienteCpf(cpf, pageable);
    }

    @Transactional(readOnly = true)
    public Page<ClienteVagaProjection> buscarTodosPorUsuarioId(Long id, Pageable pageable) {
        return repository.findAllByClienteUsuarioId(id, pageable);
    }

    @Transactional(readOnly = true)
    public Page<ClienteVagaProjection> buscarTodos(Pageable pageable) {
        return repository.findAllBy(pageable);
    }

    @Transactional(readOnly = true)
    public Optional<ClienteVaga> buscarAtivoPorUsuarioId(Long id) {
        return repository.findFirstByClienteUsuarioIdAndDataSaidaIsNull(id);
    }

    @Transactional(readOnly = true)
    public List<ClienteVagaProjection> buscarAtivos() {
        return repository.findAllByDataSaidaIsNullOrderByDataEntradaDesc();
    }

    @Transactional(readOnly = true)
    public boolean existeAtivoPorCliente(Long clienteId) {
        return repository.existsByClienteIdAndDataSaidaIsNull(clienteId);
    }

    @Transactional(readOnly = true)
    public boolean existeAtivoPorPlaca(String placa) {
        return repository.existsByPlacaAndDataSaidaIsNull(placa);
    }
}
