import {Button, Card, Checkbox, FieldError, Form, InputGroup, Label, Link, TextField, Typography} from "@heroui/react";
import {Icon} from "@iconify-icon/react";
import {useState} from "react";

export default function Login()
{
    const [passwordVisible, setPasswordVisible] = useState(false);
    return (
        <div className={"flex justify-center items-center h-dvh"}>
            <Card className={"w-140 px-8"}>
                <Card.Header>
                    <Card.Title><Typography.Heading>Login</Typography.Heading></Card.Title>
                    <Card.Description>To view our demo app, please enter you're credentials</Card.Description>
                </Card.Header>
                <Card.Content className="pt-2 pb-4">
                    <Form id={"login-form"} className={"flex flex-col gap-2"} onSubmit={(e) => console.log("Login attempt", e)}>
                        <TextField isRequired name={"email"}>
                            <Label htmlFor={"email-input"}>Email</Label>
                            <InputGroup fullWidth className={"bg-background-secondary/30 hover:bg-background-secondary"}>
                                <InputGroup.Prefix><Icon icon={"lucide:mail"}/></InputGroup.Prefix>
                                <InputGroup.Input id={"email-input"} type={"email"} placeholder={"john.doe@example.com"}/>
                            </InputGroup>
                            <FieldError>{(validation) => validation.validationErrors.join(", ")}</FieldError>
                        </TextField>

                        <TextField isRequired name={"password"}>
                            <Label htmlFor={"password-input"}>Password</Label>
                            <InputGroup fullWidth className={"bg-background-secondary/30 hover:bg-background-secondary"}>
                                <InputGroup.Input id={"password-input"} type={passwordVisible ? "text" : "password"} placeholder={"Enter password..."}/>
                                <InputGroup.Suffix>
                                    <Button
                                        isIconOnly
                                        size={"sm"}
                                        variant={"ghost"}
                                        onPress={() => setPasswordVisible(prev => !prev)}
                                        className={"rounded-sm"}
                                        excludeFromTabOrder
                                    >
                                        {passwordVisible ? <Icon icon={"lucide:eye"}/> : <Icon icon={"lucide:eye-off"}/>}
                                    </Button>
                                </InputGroup.Suffix>
                            </InputGroup>
                            <FieldError>{(validation) => validation.validationErrors.join(", ")}</FieldError>
                        </TextField>

                        <Checkbox id="secondary" name="remember-me" variant="secondary" className={"my-2"}>
                            <Checkbox.Content className={"flex flex-row gap-2 items-center"}>
                                <Checkbox.Control>
                                    <Checkbox.Indicator/>
                                </Checkbox.Control>
                                Remember Me?
                            </Checkbox.Content>
                        </Checkbox>
                    </Form>
                </Card.Content>
                <Card.Footer className={"flex flex-row gap-2 items-start"}>
                    <Typography.Paragraph>Already have an account? <Link href={"/signup"} className={"text-accent"}>Signup!</Link></Typography.Paragraph>
                    <Button className={"ml-auto"} form={"login-form"} type={"submit"}>Login</Button>
                </Card.Footer>

            </Card>

        </div>
    );
}