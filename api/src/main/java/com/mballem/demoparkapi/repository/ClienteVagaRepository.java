package com.mballem.demoparkapi.repository;

import com.mballem.demoparkapi.entity.ClienteVaga;
import com.mballem.demoparkapi.repository.projection.ClienteVagaProjection;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface ClienteVagaRepository extends JpaRepository<ClienteVaga, Long> {
    Optional<ClienteVaga> findByReciboAndDataSaidaIsNull(String recibo);

    long countByClienteCpfAndDataSaidaIsNotNull(String cpf);

    Page<ClienteVagaProjection> findAllByClienteCpf(String cpf, Pageable pageable);

    Page<ClienteVagaProjection> findAllByClienteUsuarioId(Long id, Pageable pageable);

    Page<ClienteVagaProjection> findAllBy(Pageable pageable);

    Optional<ClienteVaga> findFirstByClienteUsuarioIdAndDataSaidaIsNull(Long id);

    boolean existsByClienteIdAndDataSaidaIsNull(Long id);

    boolean existsByPlacaAndDataSaidaIsNull(String placa);

    List<ClienteVagaProjection> findAllByDataSaidaIsNullOrderByDataEntradaDesc();

    List<ClienteVagaProjection> findTop8ByOrderByDataModificacaoDesc();

    List<ClienteVaga> findAllByDataEntradaGreaterThanEqual(LocalDateTime inicio);

    long countByDataSaidaIsNull();

    long countByDataEntradaGreaterThanEqual(LocalDateTime inicio);

    long countByDataSaidaGreaterThanEqual(LocalDateTime inicio);

    @Query("select coalesce(sum(cv.valor - coalesce(cv.desconto, 0)), 0) from ClienteVaga cv where cv.dataSaida >= :inicio")
    BigDecimal somarFaturamentoDesde(LocalDateTime inicio);

    @Query("select coalesce(sum(cv.valor - coalesce(cv.desconto, 0)), 0) from ClienteVaga cv where cv.dataSaida is not null")
    BigDecimal somarFaturamentoTotal();
}
