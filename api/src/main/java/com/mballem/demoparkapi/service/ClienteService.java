package com.mballem.demoparkapi.service;

import com.mballem.demoparkapi.entity.Cliente;
import com.mballem.demoparkapi.exception.CpfUniqueViolationException;
import com.mballem.demoparkapi.exception.EntityNotFoundException;
import com.mballem.demoparkapi.exception.SolicitacaoVagaException;
import com.mballem.demoparkapi.repository.ClienteRepository;
import com.mballem.demoparkapi.repository.projection.ClienteProjection;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@RequiredArgsConstructor
@Service
public class ClienteService {

    private final ClienteRepository clienteRepository;
    private final UsuarioService usuarioService;

    @Transactional
    public Cliente salvar(Cliente cliente) {
        try {
            return clienteRepository.save(cliente);
        } catch (DataIntegrityViolationException ex) {
            throw new CpfUniqueViolationException(cliente.getCpf());
        }
    }

    @Transactional(readOnly = true)
    public Cliente buscarPorId(Long id) {
        return clienteRepository.findById(id).orElseThrow(
                () -> new EntityNotFoundException("Cliente", String.valueOf(id))
        );
    }

    @Transactional(readOnly = true)
    public Page<ClienteProjection> buscarTodos(Pageable pageable) {
        return clienteRepository.findAllPageable(pageable);
    }

    @Transactional(readOnly = true)
    public Cliente buscarPorUsuarioId(Long id) {
        Cliente cliente = clienteRepository.findByUsuarioId(id);
        if (cliente == null) {
            throw new EntityNotFoundException("Cliente", "usuario " + id);
        }
        return cliente;
    }

    @Transactional(readOnly = true)
    public Cliente buscarPorCpf(String cpf) {
        return clienteRepository.findByCpf(cpf).orElseThrow(
                () -> new EntityNotFoundException("Cliente", cpf)
        );
    }

    @Transactional
    public Cliente buscarOuCriarParaUsuario(Long usuarioId, String nome, String cpf) {
        Cliente existente = clienteRepository.findByUsuarioId(usuarioId);
        if (existente != null) {
            return existente;
        }
        if (nome == null || nome.isBlank() || cpf == null || cpf.isBlank()) {
            throw new SolicitacaoVagaException("exception.solicitacao.dadosCliente", HttpStatus.UNPROCESSABLE_ENTITY);
        }
        String cpfNumerico = cpf.replaceAll("\\D", "");
        if (clienteRepository.existsByCpf(cpfNumerico)) {
            throw new CpfUniqueViolationException(cpfNumerico);
        }
        Cliente cliente = new Cliente();
        cliente.setNome(nome.trim());
        cliente.setCpf(cpfNumerico);
        cliente.setUsuario(usuarioService.buscarPorId(usuarioId));
        return salvar(cliente);
    }
}
