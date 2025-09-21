	package com.example.demo;
	
	import org.springframework.boot.CommandLineRunner;
	import org.springframework.stereotype.Component;
	
	import com.example.demo.service.AdminService;
	import com.example.demo.service.UserService;
	import com.example.demo.vo.Admin;
	import com.example.demo.vo.Member;
	
	@Component
	public class DataInitializer implements CommandLineRunner {
	    private final UserService userService;
	    private final AdminService adminService;
	
	    public DataInitializer(UserService userService, AdminService adminService) {
	    	this.userService =  userService;
	        this.adminService = adminService;
	    }

		@Override
		public void run(String... args) {
			if (adminService.getbyemail("admin@example.com") == null) {
				Admin admin = new Admin("admin", "Admin#12345", "Admin", "admin@example.com");
				adminService.signup(admin);
			}

			if (!userService.existsByUserid("12")) {
				Member newMember = new Member("12", "Passw0rd!", "테스트유저", "user12@example.com", "서울");
				userService.signup(newMember);
			}
		}

	}