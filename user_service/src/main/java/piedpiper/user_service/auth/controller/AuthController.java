package piedpiper.user_service.auth.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import piedpiper.user_service.auth.TokenService;
import piedpiper.user_service.auth.dtos.JwtDto;
import piedpiper.user_service.auth.dtos.SignInDto;
import piedpiper.user_service.auth.dtos.SignUpDto;
import piedpiper.user_service.auth.service.AuthService;
import piedpiper.user_service.user.entity.User;
import jakarta.validation.Valid;


@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    @Autowired
    private AuthenticationManager authenticationManager;
    @Autowired
    private AuthService authService;
    @Autowired
    private TokenService tokenService;

    @PostMapping("/signup")
    public ResponseEntity<?> signUp(@RequestBody @Valid SignUpDto dto) {
        authService.signUp(dto);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @PostMapping("/signin")
    public ResponseEntity<JwtDto> signIn(@RequestBody @Valid SignInDto dto) {
        var loginData = new UsernamePasswordAuthenticationToken(dto.login(), dto.password());

        var authUser = authenticationManager.authenticate(loginData);

        var accessToken = tokenService.generateAccessToken((User) authUser);

        return ResponseEntity.ok(new JwtDto(accessToken));
    }

}
