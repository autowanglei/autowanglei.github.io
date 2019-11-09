# springboot学习

## springboot：

 旨在简化创建产品级的 Spring 应用和服务，简化了配置文件，使用嵌入式web服务器，含有诸多开箱即用微服务功能，可以和spring cloud联合部署。 

## Springboot启动机制

- Springboot集成了SpringMVC，内置了Tomcat。启动Tomcat，集成SpringMVC的流程：通过注解@SpringBootApplication->@EnableAutoConfiguration -> @Import 加载spring-boot-autoconfigure中META-INF/spring.factories中所有的配置类，其中EmbeddedWebServerFactoryCustomizerAutoConfiguration、ServletWebServerFactoryAutoConfiguration内置集成和启动Tomcat，配置类WebMvcAutoConfiguration使用EnableWebMvc集成SpringMVC的功能。

