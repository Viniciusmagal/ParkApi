package com.mballem.demoparkapi.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JasperExportManager;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;
import java.sql.Connection;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@Service
public class JasperService {

    private final ResourceLoader resourceLoader;
    private final DataSource dataSource;

    private static final String JASPER_DIRETORIO = "classpath:reports/";

    public byte[] gerarPdf(String cpf) {
        Map<String, Object> params = new HashMap<>();
        params.put("IMAGEM_DIRETORIO", JASPER_DIRETORIO);
        params.put("REPORT_LOCALE", new Locale("pt", "BR"));
        params.put("CPF", cpf);
        try (Connection connection = dataSource.getConnection()) {
            Resource resource = resourceLoader.getResource(JASPER_DIRETORIO.concat("estacionamentos.jasper"));
            try (InputStream stream = resource.getInputStream()) {
                JasperPrint print = JasperFillManager.fillReport(stream, params, connection);
                return JasperExportManager.exportReportToPdf(print);
            }
        } catch (IOException | JRException | SQLException e) {
            log.error("Falha ao gerar relatório PDF", e);
            throw new RuntimeException(e);
        }
    }
}
