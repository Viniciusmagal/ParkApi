package com.mballem.demoparkapi.service;

import com.mballem.demoparkapi.entity.Vaga;
import com.mballem.demoparkapi.exception.CodigoUniqueViolationException;
import com.mballem.demoparkapi.exception.EntityNotFoundException;
import com.mballem.demoparkapi.exception.VagaDisponivelException;
import com.mballem.demoparkapi.repository.VagaRepository;
import com.mballem.demoparkapi.web.dto.DisponibilidadeDto;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static com.mballem.demoparkapi.entity.Vaga.StatusVaga.LIVRE;
import static com.mballem.demoparkapi.entity.Vaga.StatusVaga.OCUPADA;

@RequiredArgsConstructor
@Service
public class VagaService {

    private final VagaRepository vagaRepository;

    @Transactional
    public Vaga salvar(Vaga vaga) {
        try {
            return vagaRepository.save(vaga);
        } catch (DataIntegrityViolationException ex) {
            throw new CodigoUniqueViolationException("Vaga", vaga.getCodigo());
        }
    }

    @Transactional(readOnly = true)
    public Vaga buscarPorCodigo(String codigo) {
        return vagaRepository.findByCodigo(codigo).orElseThrow(
                () -> new EntityNotFoundException("Vaga", codigo)
        );
    }

    @Transactional(readOnly = true)
    public Vaga buscarPorVagaLivre() {
        return vagaRepository.findFirstByStatus(LIVRE).orElseThrow(
                () -> new VagaDisponivelException()
        );
    }

    @Transactional(readOnly = true)
    public List<Vaga> buscarTodas() {
        return vagaRepository.findAllByOrderByCodigoAsc();
    }

    @Transactional(readOnly = true)
    public DisponibilidadeDto buscarDisponibilidade() {
        long livres = vagaRepository.countByStatus(LIVRE);
        long ocupadas = vagaRepository.countByStatus(OCUPADA);
        return new DisponibilidadeDto(livres + ocupadas, livres, ocupadas);
    }
}
