package com.mballem.demoparkapi.config;

import com.mballem.demoparkapi.entity.Usuario;
import com.mballem.demoparkapi.entity.Vaga;
import com.mballem.demoparkapi.repository.UsuarioRepository;
import com.mballem.demoparkapi.repository.VagaRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(name = "app.seed.enabled", havingValue = "true")
public class DataInitializer implements CommandLineRunner {

    private static final List<String> VAGAS = List.of(
            "A-01", "A-02", "A-03", "A-04", "A-05", "A-06",
            "B-01", "B-02", "B-03", "B-04", "B-05", "B-06"
    );

    private final VagaRepository vagaRepository;
    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void run(String... args) {
        for (String codigo : VAGAS) {
            if (!vagaRepository.existsByCodigo(codigo)) {
                Vaga vaga = new Vaga();
                vaga.setCodigo(codigo);
                vaga.setStatus(Vaga.StatusVaga.LIVRE);
                vagaRepository.save(vaga);
            }
        }
        criarUsuario("admin@park.com", Usuario.Role.ROLE_ADMIN);
        criarUsuario("cliente@park.com", Usuario.Role.ROLE_CLIENTE);
        log.info("Dados iniciais prontos: {} vagas, admin@park.com e cliente@park.com com senha 123456", vagaRepository.count());
    }

    private void criarUsuario(String username, Usuario.Role role) {
        if (usuarioRepository.existsByUsername(username)) {
            return;
        }
        Usuario usuario = new Usuario();
        usuario.setUsername(username);
        usuario.setPassword(passwordEncoder.encode("123456"));
        usuario.setRole(role);
        usuarioRepository.save(usuario);
    }
}
